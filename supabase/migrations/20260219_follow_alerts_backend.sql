-- RodeoDaily follow-alert backend schema for Supabase
-- Created: 2026-02-19

create extension if not exists pgcrypto;

create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  installation_id text unique not null,
  apns_token text,
  app_bundle_id text,
  platform text not null default 'ios',
  timezone text not null default 'America/Denver',
  locale text,
  push_enabled boolean not null default true,
  quiet_hours_enabled boolean not null default true,
  quiet_start_hour smallint not null default 22 check (quiet_start_hour between 0 and 23),
  quiet_end_hour smallint not null default 7 check (quiet_end_hour between 0 and 23),
  daily_cap_enabled boolean not null default true,
  daily_cap_count integer not null default 6 check (daily_cap_count between 1 and 50),
  digest_enabled boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.follow_rules (
  id uuid primary key default gen_random_uuid(),
  installation_id text not null references public.devices(installation_id) on delete cascade,
  athlete_id integer not null,
  athlete_name text not null,
  event text not null,
  payout_threshold numeric not null default 10000,
  alert_rank_enabled boolean not null default true,
  alert_result_enabled boolean not null default true,
  alert_threshold_enabled boolean not null default false,
  muted_until timestamptz,
  last_known_rank text not null default 'Unranked',
  last_known_result_id integer not null default 0,
  last_known_earnings numeric not null default 0,
  last_checked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (installation_id, athlete_id, event)
);

create table if not exists public.alert_events (
  id bigint generated always as identity primary key,
  installation_id text not null,
  athlete_id integer not null,
  athlete_name text not null,
  event text not null,
  alert_type text not null,
  title text not null,
  message text not null,
  dedupe_key text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued',
  created_at timestamptz not null default now(),
  delivered_at timestamptz,
  unique (dedupe_key)
);

create table if not exists public.notification_daily_state (
  installation_id text not null,
  day date not null,
  delivered_count integer not null default 0,
  pending_digest_count integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (installation_id, day)
);

create index if not exists idx_follow_rules_installation on public.follow_rules(installation_id);
create index if not exists idx_follow_rules_athlete on public.follow_rules(athlete_id);
create index if not exists idx_alert_events_installation_created on public.alert_events(installation_id, created_at desc);
create index if not exists idx_alert_events_status on public.alert_events(status);

alter table public.devices enable row level security;
alter table public.follow_rules enable row level security;
alter table public.alert_events enable row level security;
alter table public.notification_daily_state enable row level security;

-- Deny direct client access for now; backend service_role handles writes.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'devices' and policyname = 'service_role_only_devices'
  ) then
    create policy "service_role_only_devices"
      on public.devices for all
      using (auth.role() = 'service_role')
      with check (auth.role() = 'service_role');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'follow_rules' and policyname = 'service_role_only_follow_rules'
  ) then
    create policy "service_role_only_follow_rules"
      on public.follow_rules for all
      using (auth.role() = 'service_role')
      with check (auth.role() = 'service_role');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'alert_events' and policyname = 'service_role_only_alert_events'
  ) then
    create policy "service_role_only_alert_events"
      on public.alert_events for all
      using (auth.role() = 'service_role')
      with check (auth.role() = 'service_role');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'notification_daily_state' and policyname = 'service_role_only_notification_daily_state'
  ) then
    create policy "service_role_only_notification_daily_state"
      on public.notification_daily_state for all
      using (auth.role() = 'service_role')
      with check (auth.role() = 'service_role');
  end if;
end $$;
