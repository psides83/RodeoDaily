import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type FollowInput = {
  athlete_id: number;
  athlete_name: string;
  event: string;
  alert_rank_enabled?: boolean;
  alert_result_enabled?: boolean;
  alert_rodeo_result_enabled?: boolean;
  muted_until?: string | null;
};

type ExistingFollowRule = {
  id: string;
  athlete_id: number;
  event: string;
  payout_threshold: number | null;
  last_known_rank: string | null;
  last_known_result_id: number | null;
  last_known_rodeo_result_id: number | null;
  last_known_earnings: number | null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const installationId = String(body.installation_id || "");
    const follows = (body.follows || []) as FollowInput[];

    if (!installationId) {
      return new Response(JSON.stringify({ error: "installation_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const sanitized = follows
      .filter((f) => Number.isFinite(f.athlete_id) && f.event)
      .map((f) => ({
        installation_id: installationId,
        athlete_id: f.athlete_id,
        athlete_name: f.athlete_name || "Athlete",
        event: f.event,
        alert_rank_enabled: f.alert_rank_enabled ?? true,
        alert_result_enabled: f.alert_result_enabled ?? true,
        alert_rodeo_result_enabled: f.alert_rodeo_result_enabled ?? true,
        muted_until: f.muted_until ?? null,
        updated_at: new Date().toISOString(),
      }));

    const { data: existingRows, error: existingError } = await supabase
      .from("follow_rules")
      .select(
        "id, athlete_id, event, payout_threshold, last_known_rank, last_known_result_id, last_known_rodeo_result_id, last_known_earnings",
      )
      .eq("installation_id", installationId);

    if (existingError) throw existingError;

    const existingByKey = new Map<string, ExistingFollowRule>();
    (existingRows as ExistingFollowRule[] | null)?.forEach((row) => {
      existingByKey.set(`${row.athlete_id}:${row.event}`, row);
    });

    if (sanitized.length === 0) {
      await supabase
        .from("follow_rules")
        .delete()
        .eq("installation_id", installationId);

      return new Response(JSON.stringify({ ok: true, count: 0 }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const upserts = sanitized.map((row) => {
      const existing = existingByKey.get(`${row.athlete_id}:${row.event}`);
      return {
        ...row,
        payout_threshold: existing?.payout_threshold ?? 10000,
        last_known_rank: existing?.last_known_rank ?? "Unranked",
        last_known_result_id: existing?.last_known_result_id ?? 0,
        last_known_rodeo_result_id: existing?.last_known_rodeo_result_id ?? 0,
        last_known_earnings: existing?.last_known_earnings ?? 0,
        created_at: existing ? undefined : new Date().toISOString(),
      };
    });

    const { error: upsertError } = await supabase
      .from("follow_rules")
      .upsert(upserts, {
        onConflict: "installation_id,athlete_id,event",
      });

    if (upsertError) throw upsertError;

    const keepKeys = new Set(sanitized.map((row) => `${row.athlete_id}:${row.event}`));
    const staleIds = (existingRows as ExistingFollowRule[] | null)
      ?.filter((row) => !keepKeys.has(`${row.athlete_id}:${row.event}`))
      .map((row) => row.id) ?? [];

    if (staleIds.length > 0) {
      const { error: deleteStaleError } = await supabase
        .from("follow_rules")
        .delete()
        .in("id", staleIds);

      if (deleteStaleError) throw deleteStaleError;
    }

    return new Response(JSON.stringify({ ok: true, count: sanitized.length }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
