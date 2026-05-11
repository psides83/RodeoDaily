import { SignJWT, importPKCS8 } from "npm:jose@5.9.6";

let cachedToken: { value: string; exp: number } | null = null;

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing required env: ${name}`);
  return value;
}

async function apnsJwt(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.exp > now + 60) {
    return cachedToken.value;
  }

  const teamId = requiredEnv("APPLE_TEAM_ID");
  const keyId = requiredEnv("APPLE_KEY_ID");
  const privateKeyRaw = requiredEnv("APPLE_PRIVATE_KEY").replace(/\\n/g, "\n");

  const privateKey = await importPKCS8(privateKeyRaw, "ES256");
  const token = await new SignJWT({})
    .setProtectedHeader({ alg: "ES256", kid: keyId })
    .setIssuer(teamId)
    .setIssuedAt(now)
    .setExpirationTime(now + 60 * 60)
    .sign(privateKey);

  cachedToken = { value: token, exp: now + 60 * 60 };
  return token;
}

export async function sendApns(options: {
  deviceToken: string;
  alertTitle: string;
  alertBody: string;
  userInfo?: Record<string, unknown>;
  badgeCount?: number;
}) {
  const bundleId = requiredEnv("APPLE_BUNDLE_ID");
  const environment = (Deno.env.get("APNS_ENV") || "sandbox").toLowerCase();
  const host = environment === "production" ? "api.push.apple.com" : "api.sandbox.push.apple.com";
  const jwt = await apnsJwt();

  const payload = {
    aps: {
      alert: {
        title: options.alertTitle,
        body: options.alertBody,
      },
      sound: "default",
      category: "FOLLOW_ALERT_CATEGORY",
      badge: options.badgeCount ?? 1,
    },
    ...(options.userInfo || {}),
  };

  const response = await fetch(`https://${host}/3/device/${options.deviceToken}`, {
    method: "POST",
    headers: {
      authorization: `bearer ${jwt}`,
      "apns-topic": bundleId,
      "apns-push-type": "alert",
      "apns-priority": "10",
      "content-type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`APNs failed (${response.status}): ${body}`);
  }
}
