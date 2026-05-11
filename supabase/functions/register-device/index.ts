import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

    if (!body.installation_id) {
      return new Response(JSON.stringify({ error: "installation_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const payload = {
      installation_id: String(body.installation_id),
      apns_token: body.apns_token ? String(body.apns_token) : null,
      app_bundle_id: body.app_bundle_id ? String(body.app_bundle_id) : null,
      timezone: body.timezone ? String(body.timezone) : "America/Denver",
      locale: body.locale ? String(body.locale) : null,
      push_enabled: body.push_enabled ?? true,
      quiet_hours_enabled: body.quiet_hours_enabled ?? true,
      quiet_start_hour: body.quiet_start_hour ?? 22,
      quiet_end_hour: body.quiet_end_hour ?? 7,
      daily_cap_enabled: body.daily_cap_enabled ?? true,
      daily_cap_count: body.daily_cap_count ?? 6,
      digest_enabled: body.digest_enabled ?? true,
      last_seen_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    const { error } = await supabase
      .from("devices")
      .upsert(payload, { onConflict: "installation_id" });

    if (error) {
      throw error;
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
