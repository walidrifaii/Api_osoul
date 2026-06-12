import { App, cert, getApp, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
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
};

function isLegacyExpoToken(token: string): boolean {
  return token.startsWith("ExponentPushToken[");
}

export async function getAllUserPushTokens(): Promise<PushRecipient[]> {
  let result;
  try {
    result = await pool.query(
      `SELECT DISTINCT expo_push_token, push_platform
       FROM users
       WHERE expo_push_token IS NOT NULL
         AND TRIM(expo_push_token) <> ''`
    );
  } catch {
    result = await pool.query(
      `SELECT DISTINCT expo_push_token, NULL AS push_platform
       FROM users
       WHERE expo_push_token IS NOT NULL
         AND TRIM(expo_push_token) <> ''`
    );
  }

  return result.rows
    .map((row: { expo_push_token: string; push_platform: string | null }) => ({
      token: row.expo_push_token.trim(),
      platform: row.push_platform,
    }))
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

async function sendFcmToRecipient(
  recipient: PushRecipient,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  const app = ensureFirebaseApp();
  const messaging = getMessaging(app);

  if (recipient.platform === "ios") {
    await messaging.send({
      token: recipient.token,
      notification: { title, body },
      data,
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });
    return;
  }

  await messaging.send({
    token: recipient.token,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: {
        channelId: ANDROID_NOTIFICATION_CHANNEL,
        icon: "notification_icon",
      },
    },
  });
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
          `FCM notification failed for token ${recipient.token.slice(0, 12)}...:`,
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
