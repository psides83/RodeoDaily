import type { FollowSnapshot } from "./types.ts";

const BASE_URL = "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx";

export type RodeoResultSnapshot = {
  rodeoId: number;
  rodeoName: string;
};

function eventNameForCode(code: string): string {
  switch (code.toUpperCase()) {
    case "BB": return "Breakaway";
    case "BR": return "Barrel";
    case "SB": return "Steer Wrestling";
    case "SW": return "Steer Wrestling";
    case "TD": return "Tie-Down";
    case "TR": return "Team Roping";
    case "LB": return "Barrel";
    case "GB": return "Breakaway";
    case "SR": return "Steer Roping";
    default: return code;
  }
}

function prcaSeasonYear(now = new Date()): number {
  const month = now.getUTCMonth() + 1;
  const year = now.getUTCFullYear();
  return month >= 10 ? year + 1 : year;
}

function toNumber(value: unknown, fallback = 0): number {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function parseRank(rankings: unknown[], eventCode: string): string {
  const eventMatch = eventNameForCode(eventCode).toLowerCase();
  const season = prcaSeasonYear();

  const match = rankings.find((row: any) => {
    const rowSeason = toNumber(row?.Season, 0);
    const eventName = String(row?.EventName || "").toLowerCase();
    return rowSeason === season && eventName.includes(eventMatch);
  }) as any;

  return match?.Rank ? String(match.Rank) : "Unranked";
}

function parseEarnings(career: unknown[], eventCode: string): number {
  const season = prcaSeasonYear();

  const match = career.find((row: any) => {
    return toNumber(row?.Season, 0) === season && String(row?.EventType || "") === eventCode;
  }) as any;

  return toNumber(match?.Earnings, 0);
}

function parseLatestResult(results: unknown[], averages: unknown[], eventCode: string): {
  id: number;
  rodeoName: string | null;
} {
  const mappedResults = (results || []).flatMap((row: any) => {
    if (String(row?.EventType || "") !== eventCode) return [];
    return [{
      endDate: String(row?.EndDate || ""),
      id: toNumber(row?.RodeoResultId, 0),
      rodeoName: String(row?.RodeoName || "").trim() || null,
    }];
  });

  const mappedAverages = (averages || []).flatMap((row: any) => {
    if (String(row?.EventType || "") !== eventCode) return [];
    return [{
      endDate: String(row?.EndDate || ""),
      id: toNumber(row?.AggregateId, 0),
      rodeoName: String(row?.RodeoName || "").trim() || null,
    }];
  });

  const combined = [...mappedResults, ...mappedAverages];
  combined.sort((a, b) => {
    if (a.endDate === b.endDate) return b.id - a.id;
    return a.endDate > b.endDate ? -1 : 1;
  });

  return {
    id: combined[0]?.id || 0,
    rodeoName: combined[0]?.rodeoName || null,
  };
}

function eventKeyword(eventCode: string): string {
  switch (eventCode.toUpperCase()) {
    case "BB": return "bareback";
    case "SW": return "steer";
    case "SB": return "saddle";
    case "TD": return "tie-down";
    case "GB": return "racing";
    case "BR": return "bull";
    case "TR": return "team";
    case "LB": return "breakaway";
    case "SR": return "steer roping";
    default: return eventCode.toLowerCase();
  }
}

function matchesEvent(html: string, eventCode: string): boolean {
  const content = html.toLowerCase();
  const code = eventCode.toUpperCase();

  if (code === "BR") {
    return content.includes("bull") && content.includes("riding");
  }

  return content.includes(eventKeyword(code));
}

export async function fetchLatestEventRodeoResult(eventCode: string): Promise<RodeoResultSnapshot | null> {
  const url = `${BASE_URL}/schedule?type=results&page_size=24&index=1&search_term=&search_type=&tourId=&circuitId=&combine_results=true&active=true`;
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Results schedule fetch failed (${response.status}) for event ${eventCode}`);
  }

  const json = await response.json();
  const data = Array.isArray(json?.data) ? json.data : [];

  const match = data.find((row: any) => {
    const html = String(row?.ApResults || "");
    return html.length > 0 && matchesEvent(html, eventCode);
  }) as any;

  if (!match) {
    return null;
  }

  return {
    rodeoId: toNumber(match?.RodeoId, 0),
    rodeoName: String(match?.Name || "Rodeo Results"),
  };
}

export async function fetchFollowSnapshot(athleteId: number, eventCode: string): Promise<FollowSnapshot> {
  const url = `${BASE_URL}/athlete?id=${athleteId}`;
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Athlete fetch failed (${response.status}) for athlete ${athleteId}`);
  }

  const json = await response.json();
  const data = json?.data || {};

  const rankings = Array.isArray(data.Rankings) ? data.Rankings : [];
  const career = Array.isArray(data.Career) ? data.Career : [];
  const results = Array.isArray(data.Results) ? data.Results : [];
  const averages = Array.isArray(data.Averages) ? data.Averages : [];

  const latestResult = parseLatestResult(results, averages, eventCode);

  return {
    rank: parseRank(rankings, eventCode),
    earnings: parseEarnings(career, eventCode),
    latestResultId: latestResult.id,
    latestResultRodeoName: latestResult.rodeoName,
  };
}
