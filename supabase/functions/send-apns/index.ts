import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { sendApns } from "../_shared/apns.ts";

Deno.serve(async (req) => {
  try {
    const body = await req.json();
    const limit = Number.isFinite(body.limit) ? Number(body.limit) : 100;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: queued, error } = await supabase
      .from("alert_events")
      .select("id, installation_id, title, message, payload")
      .eq("status", "queued")
      .order("created_at", { ascending: true })
      .limit(limit);

    if (error) throw error;

    let sent = 0;
    let failed = 0;
    const badgeByInstallation = new Map<string, number>();

    for (const alert of queued || []) {
      const { data: device } = await supabase
        .from("devices")
        .select("apns_token")
        .eq("installation_id", alert.installation_id)
        .single();

      if (!device?.apns_token) {
        await supabase
          .from("alert_events")
          .update({ status: "failed" })
          .eq("id", alert.id);
        failed += 1;
        continue;
      }

      try {
        const currentBadge = (badgeByInstallation.get(alert.installation_id) || 0) + 1;
        badgeByInstallation.set(alert.installation_id, currentBadge);

        await sendApns({
          deviceToken: device.apns_token,
          alertTitle: alert.title,
          alertBody: alert.message,
          userInfo: alert.payload || {},
          badgeCount: currentBadge,
        });

        await supabase
          .from("alert_events")
          .update({ status: "sent", delivered_at: new Date().toISOString() })
          .eq("id", alert.id);

        sent += 1;
      } catch {
        await supabase
          .from("alert_events")
          .update({ status: "failed" })
          .eq("id", alert.id);
        failed += 1;
      }
    }

    return Response.json({ ok: true, sent, failed, queued: queued?.length || 0 });
  } catch (error) {
    return Response.json({ ok: false, error: String(error) }, { status: 500 });
  }
});
