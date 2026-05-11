import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { sendApns } from "../_shared/apns.ts";

type TestPushBody = {
  installation_id?: string;
  title?: string;
  body?: string;
  athlete_id?: number;
  event?: string;
  alert_type?: string;
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return Response.json({ ok: false, error: "Use POST" }, { status: 405 });
  }

  try {
    const payload = (await req.json()) as TestPushBody;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    let deviceQuery = supabase
      .from("devices")
      .select("installation_id, apns_token")
      .not("apns_token", "is", null);

    if (payload.installation_id) {
      deviceQuery = deviceQuery.eq("installation_id", payload.installation_id);
    }

    const { data: deviceRows, error: deviceError } = await deviceQuery
      .order("last_seen_at", { ascending: false })
      .limit(1);

    if (deviceError) {
      throw deviceError;
    }

    const device = deviceRows?.[0];
    if (!device?.apns_token) {
      return Response.json({
        ok: false,
        error: payload.installation_id
          ? `No APNs token found for installation_id=${payload.installation_id}`
          : "No APNs token found in devices table",
      }, { status: 404 });
    }

    const title = payload.title || "RodeoDaily Test Notification";
    const body = payload.body || "APNs test succeeded from Supabase.";
    const athleteId = Number.isFinite(payload.athlete_id) ? Number(payload.athlete_id) : 72983;
    const event = payload.event || "TR";
    const alertType = payload.alert_type || "test_push";

    await sendApns({
      deviceToken: device.apns_token,
      alertTitle: title,
      alertBody: body,
      userInfo: {
        athlete_id: athleteId,
        event,
        alert_type: alertType,
      },
    });

    return Response.json({
      ok: true,
      sent_to_installation_id: device.installation_id,
      title,
      body,
      athlete_id: athleteId,
      event,
      alert_type: alertType,
    });
  } catch (error) {
    return Response.json({ ok: false, error: String(error) }, { status: 500 });
  }
});
