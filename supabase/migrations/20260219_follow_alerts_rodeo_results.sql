-- Follow alerts update:
-- 1) remove threshold-driven behavior
-- 2) add event-level "new rodeo results posted" alert control/state

alter table public.follow_rules
  add column if not exists alert_rodeo_result_enabled boolean not null default true;

alter table public.follow_rules
  add column if not exists last_known_rodeo_result_id integer not null default 0;
