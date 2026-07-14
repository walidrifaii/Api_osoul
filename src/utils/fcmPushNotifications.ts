import { App, cert, getApp, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging, Message } from "firebase-admin/messaging";
import { pool } from "../config/dp";
import { AppVersionSettings } from "./appVersionConfig";

const BATCH_SIZE = 10;
const BATCH_DELAY_MS = 1500;
const ANDROID_NOTIFICATION_CHANNEL = "default";

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function ensureFirebaseApp(): App {
  if (getApps().length > 0) {
    return getApp();
  }

  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw?.trim()) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT_JSON is not set. Add your Firebase service account JSON to the backend environment."
    );
  }

  const serviceAccount = JSON.parse(raw);
  return initializeApp({
    credential: cert(serviceAccount),
  });
}

export type PushRecipient = {
  token: string;
  platform: string | null;
  tokenType: string | null;
  environment: string | null;
};

type PushTokenRow = {
  expo_push_token: string;
  push_platform: string | null;
  push_token_type: string | null;
  push_environment: string | null;
};

function isLegacyExpoToken(token: string): boolean {
  return token.startsWith("ExponentPushToken[");
}

function isIosRecipient(recipient: PushRecipient): boolean {
  if (recipient.platform === "ios") {
    return true;
  }
  return recipient.tokenType === "apns";
}

function isAndroidRecipient(recipient: PushRecipient): boolean {
  // iOS may register an FCM registration token; delivery still goes through APNs.
  if (recipient.platform === "ios") {
    return false;
  }
  if (recipient.platform === "android") {
    return true;
  }
  return recipient.tokenType === "fcm";
}

function mapPushTokenRow(row: PushTokenRow): PushRecipient {
  return {
    token: row.expo_push_token.trim(),
    platform: row.push_platform,
    tokenType: row.push_token_type,
    environment: row.push_environment,
  };
}

export async function getAllUserPushTokens(): Promise<PushRecipient[]> {
  const queries = [
    `SELECT DISTINCT expo_push_token, push_platform, push_token_type, push_environment
     FROM users
     WHERE expo_push_token IS NOT NULL
       AND TRIM(expo_push_token) <> ''`,
    `SELECT DISTINCT expo_push_token, push_platform, NULL AS push_token_type, NULL AS push_environment
     FROM users
     WHERE expo_push_token IS NOT NULL
       AND TRIM(expo_push_token) <> ''`,
    `SELECT DISTINCT expo_push_token, NULL AS push_platform, NULL AS push_token_type, NULL AS push_environment
     FROM users
     WHERE expo_push_token IS NOT NULL
       AND TRIM(expo_push_token) <> ''`,
  ];

  let result;
  for (const query of queries) {
    try {
      result = await pool.query(query);
      break;
    } catch {
      continue;
    }
  }

  if (!result) {
    return [];
  }

  return result.rows
    .map((row: PushTokenRow) => mapPushTokenRow(row))
    .filter(
      (recipient: PushRecipient) =>
        recipient.token.length > 0 && !isLegacyExpoToken(recipient.token)
    );
}

function buildVersionUpdateMessage(
  settings: AppVersionSettings
): { title: string; body: string; data: Record<string, string> } {
  const version = settings.latest_version;
  return {
    title: "تحديث تطبيق أصول",
    body: `يتوفر إصدار جديد ${version}. يرجى تحديث التطبيق من المتجر.`,
    data: {
      type: "app_version_update",
      required_version: settings.required_version,
      latest_version: settings.latest_version,
      android_store_url: settings.android_store_url,
      ios_store_url: settings.ios_store_url,
    },
  };
}

function buildIosApnsConfig(
  title: string,
  body: string,
  environment: string | null
): NonNullable<Message["apns"]> {
  const apnsHeaders: Record<string, string> = {
    "apns-priority": "10",
    "apns-push-type": "alert",
  };

  // Dev/TestFlight debug builds register sandbox tokens; App Store uses production.
  // FCM routes to the correct APNs endpoint from the device token, but we persist
  // push_environment from the client for logging and future routing.
  if (environment === "sandbox" || environment === "production") {
    apnsHeaders["apns-expiration"] = String(Math.floor(Date.now() / 1000) + 86400);
  }

  return {
    headers: apnsHeaders,
    payload: {
      aps: {
        alert: {
          title,
          body,
        },
        sound: "default",
        "mutable-content": 1,
      },
    },
  };
}

function buildAndroidConfig(): NonNullable<Message["android"]> {
  return {
    priority: "high",
    notification: {
      channelId: ANDROID_NOTIFICATION_CHANNEL,
      icon: "notification_icon",
    },
  };
}

async function sendFcmToRecipient(
  recipient: PushRecipient,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  const app = ensureFirebaseApp();
  const messaging = getMessaging(app);

  const useIosPath = isIosRecipient(recipient);
  const useAndroidPath = isAndroidRecipient(recipient);

  if (!useIosPath && !useAndroidPath) {
    console.warn(
      `Skipping push token with unknown platform/type: platform=${recipient.platform}, tokenType=${recipient.tokenType}`
    );
    return;
  }

  if (useIosPath) {
    const message: Message = {
      token: recipient.token,
      notification: { title, body },
      data,
      apns: buildIosApnsConfig(title, body, recipient.environment),
    };

    await messaging.send(message);
    console.log(
      `APNs notification sent (${recipient.environment ?? "unknown-env"}) for token ${recipient.token.slice(0, 12)}...`
    );
    return;
  }

  const message: Message = {
    token: recipient.token,
    notification: { title, body },
    data,
    android: buildAndroidConfig(),
  };

  await messaging.send(message);
  console.log(
    `FCM Android notification sent for token ${recipient.token.slice(0, 12)}...`
  );
}

export type VersionNotificationResult = {
  started: boolean;
  totalRecipients: number;
  batchSize: number;
  totalBatches: number;
  version: string;
};

export function hasVersionChanged(
  previous: AppVersionSettings,
  next: AppVersionSettings
): boolean {
  return (
    previous.required_version !== next.required_version ||
    previous.latest_version !== next.latest_version
  );
}

export async function sendVersionUpdateNotificationsInBatches(
  settings: AppVersionSettings
): Promise<VersionNotificationResult> {
  const recipients = await getAllUserPushTokens();

  if (recipients.length === 0) {
    return {
      started: false,
      totalRecipients: 0,
      batchSize: BATCH_SIZE,
      totalBatches: 0,
      version: settings.latest_version,
    };
  }

  const { title, body, data } = buildVersionUpdateMessage(settings);
  const totalBatches = Math.ceil(recipients.length / BATCH_SIZE);

  for (let index = 0; index < recipients.length; index += BATCH_SIZE) {
    const batch = recipients.slice(index, index + BATCH_SIZE);
    const batchNumber = Math.floor(index / BATCH_SIZE) + 1;

    for (const recipient of batch) {
      try {
        await sendFcmToRecipient(recipient, title, body, data);
      } catch (error) {
        console.error(
          `Push notification failed (platform=${recipient.platform}, type=${recipient.tokenType}, env=${recipient.environment}, token=${recipient.token.slice(0, 12)}...):`,
          error
        );
      }
    }

    console.log(
      `Version update notifications: sent batch ${batchNumber}/${totalBatches} (${batch.length} users)`
    );

    if (index + BATCH_SIZE < recipients.length) {
      await sleep(BATCH_DELAY_MS);
    }
  }

  return {
    started: true,
    totalRecipients: recipients.length,
    batchSize: BATCH_SIZE,
    totalBatches,
    version: settings.latest_version,
  };
}

export function queueVersionUpdateNotifications(
  settings: AppVersionSettings
): void {
  void sendVersionUpdateNotificationsInBatches(settings).catch((error) => {
    console.error("Version update notification job failed:", error);
  });
}

export type AnnouncementPayload = {
  title_ar: string;
  title_en: string;
  body_ar: string;
  body_en: string;
};

export type AnnouncementNotificationResult = {
  started: boolean;
  totalRecipients: number;
  batchSize: number;
  totalBatches: number;
};

function buildAnnouncementMessage(payload: AnnouncementPayload): {
  title: string;
  body: string;
  data: Record<string, string>;
} {
  // Arabic is the default display language; English is included for the mobile app.
  return {
    title: payload.title_ar,
    body: payload.body_ar,
    data: {
      type: "announcement",
      title_ar: payload.title_ar,
      title_en: payload.title_en,
      body_ar: payload.body_ar,
      body_en: payload.body_en,
    },
  };
}

export async function sendAnnouncementNotificationsInBatches(
  payload: AnnouncementPayload
): Promise<AnnouncementNotificationResult> {
  const recipients = await getAllUserPushTokens();

  if (recipients.length === 0) {
    return {
      started: false,
      totalRecipients: 0,
      batchSize: BATCH_SIZE,
      totalBatches: 0,
    };
  }

  const { title, body, data } = buildAnnouncementMessage(payload);
  const totalBatches = Math.ceil(recipients.length / BATCH_SIZE);

  for (let index = 0; index < recipients.length; index += BATCH_SIZE) {
    const batch = recipients.slice(index, index + BATCH_SIZE);
    const batchNumber = Math.floor(index / BATCH_SIZE) + 1;

    for (const recipient of batch) {
      try {
        await sendFcmToRecipient(recipient, title, body, data);
      } catch (error) {
        console.error(
          `Announcement push failed (platform=${recipient.platform}, type=${recipient.tokenType}, env=${recipient.environment}, token=${recipient.token.slice(0, 12)}...):`,
          error
        );
      }
    }

    console.log(
      `Announcement notifications: sent batch ${batchNumber}/${totalBatches} (${batch.length} users)`
    );

    if (index + BATCH_SIZE < recipients.length) {
      await sleep(BATCH_DELAY_MS);
    }
  }

  return {
    started: true,
    totalRecipients: recipients.length,
    batchSize: BATCH_SIZE,
    totalBatches,
  };
}

export function queueAnnouncementNotifications(
  payload: AnnouncementPayload
): void {
  void sendAnnouncementNotificationsInBatches(payload).catch((error) => {
    console.error("Announcement notification job failed:", error);
  });
}
