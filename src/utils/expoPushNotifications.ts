import { pool } from "../config/dp";
import { AppVersionSettings } from "./appVersionConfig";

const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";
const BATCH_SIZE = 10;
const BATCH_DELAY_MS = 1500;
const ANDROID_NOTIFICATION_CHANNEL = "default";

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

type PushRecipient = {
  token: string;
  platform: string | null;
};

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
    .filter((recipient: PushRecipient) =>
      recipient.token.startsWith("ExponentPushToken[")
    );
}

type ExpoPushMessage = {
  to: string;
  sound?: "default";
  title?: string;
  body?: string;
  priority?: "high" | "default";
  channelId?: string;
  data: Record<string, string>;
};

function buildVersionUpdateMessage(
  recipient: PushRecipient,
  settings: AppVersionSettings
): ExpoPushMessage {
  const version = settings.latest_version;
  const title = "تحديث تطبيق أصول";
  const body = `يتوفر إصدار جديد ${version}. يرجى تحديث التطبيق من المتجر.`;
  const data = {
    type: "app_version_update",
    required_version: settings.required_version,
    latest_version: settings.latest_version,
    android_store_url: settings.android_store_url,
    ios_store_url: settings.ios_store_url,
  };

  if (recipient.platform === "ios") {
    return {
      to: recipient.token,
      sound: "default",
      title,
      body,
      data,
    };
  }

  // Android: data-only payload so expo-notifications renders with the app's icon.
  return {
    to: recipient.token,
    priority: "high",
    channelId: ANDROID_NOTIFICATION_CHANNEL,
    data: {
      title,
      message: body,
      channelId: ANDROID_NOTIFICATION_CHANNEL,
      ...data,
    },
  };
}

function buildVersionUpdateMessages(
  recipients: PushRecipient[],
  settings: AppVersionSettings
): ExpoPushMessage[] {
  return recipients.map((recipient) =>
    buildVersionUpdateMessage(recipient, settings)
  );
}

async function sendExpoPushBatch(messages: ExpoPushMessage[]): Promise<void> {
  const response = await fetch(EXPO_PUSH_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify(messages),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Expo push failed (${response.status}): ${errorBody}`);
  }

  const result = await response.json();
  const tickets = Array.isArray(result.data) ? result.data : [result.data];
  const errors = tickets.filter(
    (ticket: { status?: string }) => ticket?.status === "error"
  );

  if (errors.length > 0) {
    console.warn("Expo push batch had errors:", errors);
  }
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

  const messages = buildVersionUpdateMessages(recipients, settings);
  const totalBatches = Math.ceil(messages.length / BATCH_SIZE);

  for (let index = 0; index < messages.length; index += BATCH_SIZE) {
    const batch = messages.slice(index, index + BATCH_SIZE);
    const batchNumber = Math.floor(index / BATCH_SIZE) + 1;

    try {
      await sendExpoPushBatch(batch);
      console.log(
        `Version update notifications: sent batch ${batchNumber}/${totalBatches} (${batch.length} users)`
      );
    } catch (error) {
      console.error(
        `Version update notifications: batch ${batchNumber} failed:`,
        error
      );
    }

    if (index + BATCH_SIZE < messages.length) {
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
