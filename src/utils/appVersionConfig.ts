import { pool } from "../config/dp";

export type AppVersionSettings = {
  required_version: string;
  latest_version: string;
  force_update: boolean;
  android_store_url: string;
  ios_store_url: string;
};

const DEFAULT_ANDROID_STORE_URL =
  "https://play.google.com/store/apps/details?id=com.vesco.osoul";
const DEFAULT_IOS_STORE_URL =
  "https://apps.apple.com/qa/app/osoul/id6747296555?l=ar";

export function getEnvAppVersionSettings(): AppVersionSettings {
  const requiredVersion = process.env.APP_REQUIRED_VERSION || "1.2.0";

  return {
    required_version: requiredVersion,
    latest_version: process.env.APP_LATEST_VERSION || requiredVersion,
    force_update: process.env.APP_FORCE_UPDATE !== "false",
    android_store_url:
      process.env.ANDROID_STORE_URL || DEFAULT_ANDROID_STORE_URL,
    ios_store_url: process.env.IOS_STORE_URL || DEFAULT_IOS_STORE_URL,
  };
}

function mapRow(row: {
  required_version: string;
  latest_version: string;
  force_update: boolean;
  android_store_url: string;
  ios_store_url: string;
}): AppVersionSettings {
  return {
    required_version: row.required_version,
    latest_version: row.latest_version,
    force_update: row.force_update,
    android_store_url: row.android_store_url,
    ios_store_url: row.ios_store_url,
  };
}

export async function loadAppVersionSettings(): Promise<AppVersionSettings> {
  try {
    const result = await pool.query(
      `SELECT required_version, latest_version, force_update, android_store_url, ios_store_url
       FROM app_config
       WHERE id = 1`
    );

    if ((result.rowCount ?? 0) > 0) {
      return mapRow(result.rows[0]);
    }
  } catch (error) {
    console.warn(
      "app_config unavailable, using env defaults:",
      (error as Error).message
    );
  }

  return getEnvAppVersionSettings();
}

export async function saveAppVersionSettings(
  settings: AppVersionSettings
): Promise<AppVersionSettings> {
  const result = await pool.query(
    `INSERT INTO app_config (
        id,
        required_version,
        latest_version,
        force_update,
        android_store_url,
        ios_store_url,
        updated_at
      )
      VALUES (1, $1, $2, $3, $4, $5, NOW())
      ON CONFLICT (id) DO UPDATE SET
        required_version = EXCLUDED.required_version,
        latest_version = EXCLUDED.latest_version,
        force_update = EXCLUDED.force_update,
        android_store_url = EXCLUDED.android_store_url,
        ios_store_url = EXCLUDED.ios_store_url,
        updated_at = NOW()
      RETURNING required_version, latest_version, force_update, android_store_url, ios_store_url`,
    [
      settings.required_version,
      settings.latest_version,
      settings.force_update,
      settings.android_store_url,
      settings.ios_store_url,
    ]
  );

  return mapRow(result.rows[0]);
}
