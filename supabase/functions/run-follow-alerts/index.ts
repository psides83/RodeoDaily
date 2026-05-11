import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { fetchFollowSnapshot, fetchLatestEventRodeoResult } from "../_shared/prca.ts";
import type { AlertCandidate, Device, FollowRule } from "../_shared/types.ts";

const APP_BASE = Deno.env.get("APP_BASE_URL") || "https://rodeo-daily://";

function localHour(date: Date, timezone: string): number {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    hour: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const value = parts.find((p) => p.type === "hour")?.value || "0";
  return Number(value);
}

function inQuietHours(nowHour: number, start: number, end: number): boolean {
  if (start === end) return false;
  if (start < end) return nowHour >= start && nowHour < end;
  return nowHour >= start || nowHour < end;
}

function dayKey(date: Date, timezone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);
  const year = parts.find((p) => p.type === "year")?.value || "1970";
  const month = parts.find((p) => p.type === "month")?.value || "01";
  const day = parts.find((p) => p.type === "day")?.value || "01";
  return `${year}-${month}-${day}`;
}

function dedupeSuffix(now = new Date()): string {
  const bucket = Math.floor(now.getTime() / (10 * 60 * 1000));
  return String(bucket);
}

async function upsertDailyState(
  supabase: ReturnType<typeof createClient>,
  installationId: string,
  day: string,
): Promise<{ delivered_count: number; pending_digest_count: number }> {
  const { data: existing } = await supabase
    .from("notification_daily_state")
    .select("installation_id, day, delivered_count, pending_digest_count")
    .eq("installation_id", installationId)
    .eq("day", day)
    .maybeSingle();

  if (existing) {
    return {
      delivered_count: existing.delivered_count || 0,
      pending_digest_count: existing.pending_digest_count || 0,
    };
  }

  const { data: inserted } = await supabase
    .from("notification_daily_state")
    .insert({ installation_id: installationId, day, delivered_count: 0, pending_digest_count: 0 })
    .select("delivered_count, pending_digest_count")
    .single();

  return {
    delivered_count: inserted?.delivered_count || 0,
    pending_digest_count: inserted?.pending_digest_count || 0,
  };
}

function buildPayload(candidate: AlertCandidate) {
  const deepLink = candidate.alert_type === "new_rodeo_result"
    ? `${APP_BASE}results?event=${candidate.event}`
    : `${APP_BASE}athlete/${candidate.athlete_id}?event=${candidate.event}`;

  return {
    athlete_id: candidate.athlete_id,
    event: candidate.event,
    alert_type: candidate.alert_type,
    deep_link: deepLink,
  };
}

function generateAthleteAlerts(
  rule: FollowRule,
  rank: string,
  latestResultId: number,
  latestResultRodeoName: string | null,
): AlertCandidate[] {
  const nowSuffix = dedupeSuffix();
  const alerts: AlertCandidate[] = [];

  if (rule.alert_rank_enabled && rule.last_known_rank && rule.last_known_rank !== rank) {
    alerts.push({
      installation_id: rule.installation_id,
      athlete_id: rule.athlete_id,
      athlete_name: rule.athlete_name,
      event: rule.event,
      alert_type: "rank_change",
      title: "Rank changed",
      message: `${rule.athlete_name} moved from ${rule.last_known_rank} to ${rank} in ${rule.event}.`,
      dedupe_key: `${rule.installation_id}:${rule.athlete_id}:${rule.event}:rank:${nowSuffix}`,
      payload: {},
    });
  }

  if (rule.alert_result_enabled && rule.last_known_result_id > 0 && latestResultId > rule.last_known_result_id) {
    const rodeoSuffix = latestResultRodeoName ? ` at ${latestResultRodeoName}` : "";
    alerts.push({
      installation_id: rule.installation_id,
      athlete_id: rule.athlete_id,
      athlete_name: rule.athlete_name,
      event: rule.event,
      alert_type: "new_result",
      title: "New result posted",
      message: `${rule.athlete_name} has a new ${rule.event} result${rodeoSuffix}.`,
      dedupe_key: `${rule.installation_id}:${rule.athlete_id}:${rule.event}:result:${nowSuffix}`,
      payload: {},
    });
  }

  return alerts;
}

function generateRodeoAlert(
  rule: FollowRule,
  latestRodeo: { rodeoId: number; rodeoName: string } | null,
): AlertCandidate[] {
  if (!rule.alert_rodeo_result_enabled) {
    return [];
  }

  if (!latestRodeo || latestRodeo.rodeoId <= 0) {
    return [];
  }

  // Seed baseline for first run to avoid sending stale history.
  if (rule.last_known_rodeo_result_id <= 0) {
    return [];
  }

  if (latestRodeo.rodeoId <= rule.last_known_rodeo_result_id) {
    return [];
  }

  return [{
    installation_id: rule.installation_id,
    athlete_id: 0,
    athlete_name: "Rodeo Results",
    event: rule.event,
    alert_type: "new_rodeo_result",
    title: "New rodeo results posted",
    message: `${latestRodeo.rodeoName} now has ${rule.event} results.`,
    dedupe_key: `${rule.installation_id}:${rule.event}:rodeo-result:${latestRodeo.rodeoId}`,
    payload: {},
  }];
}

Deno.serve(async () => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: rows, error } = await supabase
      .from("follow_rules")
      .select("*, devices:devices!follow_rules_installation_id_fkey(*)")
      .order("updated_at", { ascending: false })
      .limit(500);

    if (error) throw error;

    let queued = 0;
    let digests = 0;
    const latestRodeoByEvent = new Map<string, { rodeoId: number; rodeoName: string } | null>();

    for (const row of rows || []) {
      const rule = row as unknown as FollowRule & { devices?: Device };
      const device = (row as any).devices as Device | undefined;
      if (!device) continue;
      if (!device.push_enabled) continue;

      const mutedUntil = rule.muted_until ? new Date(rule.muted_until) : null;
      if (mutedUntil && mutedUntil.getTime() > Date.now()) {
        continue;
      }

      const snapshot = await fetchFollowSnapshot(rule.athlete_id, rule.event);
      if (!latestRodeoByEvent.has(rule.event)) {
        latestRodeoByEvent.set(rule.event, await fetchLatestEventRodeoResult(rule.event));
      }
      const latestEventRodeo = latestRodeoByEvent.get(rule.event) ?? null;

      const generated = [
        ...generateAthleteAlerts(
          rule,
          snapshot.rank,
          snapshot.latestResultId,
          snapshot.latestResultRodeoName,
        ),
        ...generateRodeoAlert(rule, latestEventRodeo),
      ];

      await supabase
        .from("follow_rules")
        .update({
          last_known_rank: snapshot.rank,
          last_known_result_id: snapshot.latestResultId,
          last_known_rodeo_result_id: latestEventRodeo?.rodeoId ?? rule.last_known_rodeo_result_id,
          last_checked_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq("id", rule.id);

      if (generated.length === 0) continue;

      const timezone = device.timezone || "America/Denver";
      const now = new Date();
      const nowLocalHour = localHour(now, timezone);
      const today = dayKey(now, timezone);
      const state = await upsertDailyState(supabase, rule.installation_id, today);

      let delivered = state.delivered_count;
      let pendingDigest = state.pending_digest_count;

      for (const alert of generated) {
        const quiet = device.quiet_hours_enabled
          ? inQuietHours(nowLocalHour, device.quiet_start_hour, device.quiet_end_hour)
          : false;
        const capReached = device.daily_cap_enabled ? delivered >= device.daily_cap_count : false;

        if ((quiet || capReached) && device.digest_enabled) {
          pendingDigest += 1;
          continue;
        }

        alert.payload = buildPayload(alert);

        const { error: insertError } = await supabase
          .from("alert_events")
          .insert({
            installation_id: alert.installation_id,
            athlete_id: alert.athlete_id,
            athlete_name: alert.athlete_name,
            event: alert.event,
            alert_type: alert.alert_type,
            title: alert.title,
            message: alert.message,
            dedupe_key: alert.dedupe_key,
            payload: alert.payload,
            status: "queued",
          });

        if (!insertError) {
          queued += 1;
          delivered += 1;
        }
      }

      if (pendingDigest > 0 && device.digest_enabled) {
        const dedupe = `${rule.installation_id}:digest:${today}`;
        const payload = {
          alert_type: "digest",
          deep_link: `${APP_BASE}settings/follow-alerts`,
        };

        const { error: digestError } = await supabase
          .from("alert_events")
          .insert({
            installation_id: rule.installation_id,
            athlete_id: rule.athlete_id,
            athlete_name: rule.athlete_name,
            event: rule.event,
            alert_type: "digest",
            title: "Follow Alerts Digest",
            message: `You have ${pendingDigest} new follow alerts.`,
            dedupe_key: dedupe,
            payload,
            status: "queued",
          });

        if (!digestError) {
          digests += 1;
          pendingDigest = 0;
          delivered += 1;
        }
      }

      await supabase
        .from("notification_daily_state")
        .upsert({
          installation_id: rule.installation_id,
          day: today,
          delivered_count: delivered,
          pending_digest_count: pendingDigest,
          updated_at: new Date().toISOString(),
        });
    }

    // Trigger APNs send pass.
    const sendUrl = `${Deno.env.get("SUPABASE_URL")}/functions/v1/send-apns`;
    await fetch(sendUrl, {
      method: "POST",
      headers: {
        authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
        apikey: Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ limit: 500 }),
    });

    return Response.json({ ok: true, queued, digests });
  } catch (error) {
    return Response.json({ ok: false, error: String(error) }, { status: 500 });
  }
});
