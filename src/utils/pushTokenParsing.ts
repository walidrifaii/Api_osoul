export const STANDALONE_APP_ID = "com.vesco.osoul";

export function parsePushPlatform(value: unknown): "ios" | "android" | null {
  return value === "ios" || value === "android" ? value : null;
}

export function parsePushTokenType(value: unknown): "apns" | "fcm" | null {
  return value === "apns" || value === "fcm" ? value : null;
}

export function parsePushEnvironment(
  value: unknown
): "sandbox" | "production" | null {
  return value === "sandbox" || value === "production" ? value : null;
}

export function parsePreferredLanguage(value: unknown): "ar" | "en" {
  if (typeof value !== "string") {
    return "ar";
  }
  const normalized = value.trim().toLowerCase();
  if (
    normalized === "en" ||
    normalized.startsWith("en-") ||
    normalized === "english"
  ) {
    return "en";
  }
  return "ar";
}

export type ParsedPushTokenPayload = {
  pushToken: string;
  platform: "ios" | "android" | null;
  tokenType: "apns" | "fcm" | null;
  environment: "sandbox" | "production" | null;
  preferredLanguage: "ar" | "en";
  pushAppId: string | null;
};

export function validateAndParsePushTokenBody(body: {
  push_token?: unknown;
  push_platform?: unknown;
  push_token_type?: unknown;
  push_environment?: unknown;
  push_app_id?: unknown;
  preferred_language?: unknown;
  app_language?: unknown;
  language?: unknown;
}):
  | { ok: true; data: ParsedPushTokenPayload }
  | { ok: false; status: number; message: string; push_app_id?: string } {
  const {
    push_token,
    push_platform,
    push_token_type,
    push_environment,
    push_app_id,
    preferred_language,
    app_language,
    language,
  } = body;

  if (!push_token || typeof push_token !== "string") {
    return { ok: false, status: 400, message: "push_token is required" };
  }

  if (push_token.startsWith("ExponentPushToken[")) {
    return {
      ok: false,
      status: 400,
      message:
        "Expo push tokens are no longer supported. Rebuild the Osoul app to register a Firebase/APNs token.",
    };
  }

  if (push_app_id === "host.exp.exponent") {
    return {
      ok: false,
      status: 400,
      message: "Push token must be registered from the Osoul app, not Expo Go.",
    };
  }

  if (
    typeof push_app_id === "string" &&
    push_app_id.length > 0 &&
    push_app_id !== STANDALONE_APP_ID
  ) {
    return {
      ok: false,
      status: 400,
      message:
        "Push token must be registered from the Osoul app, not Expo Go or another app.",
      push_app_id,
    };
  }

  let platform = parsePushPlatform(push_platform);
  const tokenType = parsePushTokenType(push_token_type);
  const environment = parsePushEnvironment(push_environment);
  const preferredLanguage = parsePreferredLanguage(
    preferred_language ?? app_language ?? language
  );

  if (!platform && tokenType === "apns") {
    platform = "ios";
  }

  if (!platform && tokenType === "fcm") {
    platform = "android";
  }

  if (!platform && push_app_id === STANDALONE_APP_ID) {
    platform = "android";
  }

  if (platform === "android" && tokenType === "apns") {
    return {
      ok: false,
      status: 400,
      message: "Android push tokens must use push_token_type fcm.",
    };
  }

  const resolvedTokenType =
    tokenType ??
    (platform === "ios" ? "fcm" : platform === "android" ? "fcm" : null);

  return {
    ok: true,
    data: {
      pushToken: push_token.trim(),
      platform,
      tokenType: resolvedTokenType,
      environment,
      preferredLanguage,
      pushAppId: typeof push_app_id === "string" ? push_app_id : null,
    },
  };
}
