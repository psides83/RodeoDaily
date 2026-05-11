# RodeoDaily Supabase Push Backend

This folder contains a low-cost serverless backend for follow alerts.

## What is implemented
- Database tables for devices, follows, alert history, and per-day delivery counters.
- Edge function `register-device` to store APNs token + delivery prefs.
- Edge function `sync-follows` to sync followed athletes + alert settings.
- Edge function `run-follow-alerts` to poll PRCA athlete/results endpoints, compute deltas, apply guardrails, and queue pushes.
- Edge function `send-apns` to deliver queued notifications through APNs.

## Files
- `migrations/20260219_follow_alerts_backend.sql`
- `migrations/20260219_follow_alerts_rodeo_results.sql`
- `functions/register-device/index.ts`
- `functions/sync-follows/index.ts`
- `functions/run-follow-alerts/index.ts`
- `functions/send-apns/index.ts`
- `functions/_shared/apns.ts`
- `functions/_shared/prca.ts`

## Prerequisites
1. Install Supabase CLI.
2. Log in: `supabase login`
3. Link project (already set in `config.toml`):
   - `supabase link --project-ref achpzqhveafdqkdufwhk`

## Required secrets (Dashboard -> Edge Functions -> Secrets)
Set these exact keys:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `APPLE_TEAM_ID`
- `APPLE_KEY_ID`
- `APPLE_BUNDLE_ID`
- `APPLE_PRIVATE_KEY` (full `.p8` contents with `\\n` newlines)
- `APNS_ENV` (`sandbox` for debug/TestFlight validation, `production` for App Store)
- `APP_BASE_URL` (`rodeo-daily://`)

## Deploy steps
1. Apply DB schema:
   - `supabase db push`
2. Deploy functions:
   - `supabase functions deploy register-device`
   - `supabase functions deploy sync-follows`
   - `supabase functions deploy run-follow-alerts`
   - `supabase functions deploy send-apns`

## Scheduler setup (Dashboard)
Use Supabase Scheduled Functions:
- Function: `run-follow-alerts`
- Cron: `*/10 * * * *` (every 10 min)

This triggers polling + queueing + APNs send pass.

## iOS integration contract
### `register-device`
POST body:
```json
{
  "installation_id": "UUID-or-stable-install-id",
  "apns_token": "hex-device-token",
  "app_bundle_id": "PaytonSides.RodeoDaily",
  "timezone": "America/Denver",
  "locale": "en_US",
  "push_enabled": true,
  "quiet_hours_enabled": true,
  "quiet_start_hour": 22,
  "quiet_end_hour": 7,
  "daily_cap_enabled": true,
  "daily_cap_count": 6,
  "digest_enabled": true
}
```

### `sync-follows`
POST body:
```json
{
  "installation_id": "UUID-or-stable-install-id",
  "follows": [
    {
      "athlete_id": 72983,
      "athlete_name": "Athlete Name",
      "event": "TR",
      "alert_rank_enabled": true,
      "alert_result_enabled": true,
      "alert_rodeo_result_enabled": true,
      "muted_until": null
    }
  ]
}
```

## Guardrails implemented server-side
- Duplicate debounce bucket: 10 minutes.
- Quiet hours by device timezone.
- Daily cap by device setting.
- Digest fallback when quiet hours/cap suppresses immediate sends.

## Notes
- RLS is locked to `service_role` for now.
- This setup is intentionally iOS-only and APNs-direct to keep costs low.
- If you later add user auth, we can tighten RLS and use JWT-verified functions.
