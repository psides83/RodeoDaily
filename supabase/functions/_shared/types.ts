export type Device = {
  installation_id: string;
  apns_token: string | null;
  app_bundle_id: string | null;
  timezone: string;
  push_enabled: boolean;
  quiet_hours_enabled: boolean;
  quiet_start_hour: number;
  quiet_end_hour: number;
  daily_cap_enabled: boolean;
  daily_cap_count: number;
  digest_enabled: boolean;
};

export type FollowRule = {
  id: string;
  installation_id: string;
  athlete_id: number;
  athlete_name: string;
  event: string;
  alert_rank_enabled: boolean;
  alert_result_enabled: boolean;
  alert_rodeo_result_enabled: boolean;
  muted_until: string | null;
  last_known_rank: string;
  last_known_result_id: number;
  last_known_rodeo_result_id: number;
};

export type AlertCandidate = {
  installation_id: string;
  athlete_id: number;
  athlete_name: string;
  event: string;
  alert_type: "rank_change" | "new_result" | "new_rodeo_result" | "digest";
  title: string;
  message: string;
  dedupe_key: string;
  payload: Record<string, unknown>;
};

export type FollowSnapshot = {
  rank: string;
  earnings: number;
  latestResultId: number;
  latestResultRodeoName: string | null;
};
