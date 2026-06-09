import { Request, Response } from "express";
import {
  loadAppVersionSettings,
  saveAppVersionSettings,
  AppVersionSettings,
} from "../utils/appVersionConfig";

function isValidVersion(value: unknown): value is string {
  return (
    typeof value === "string" &&
    value.trim().length > 0 &&
    /^\d+(\.\d+){0,2}$/.test(value.trim())
  );
}

function isValidUrl(value: unknown): value is string {
  if (typeof value !== "string" || !value.trim()) {
    return false;
  }

  try {
    const parsed = new URL(value.trim());
    return parsed.protocol === "https:";
  } catch {
    return false;
  }
}

function parseSettingsBody(body: Request["body"]): AppVersionSettings | null {
  const requiredVersion = body?.required_version;
  const latestVersion = body?.latest_version;
  const forceUpdate = body?.force_update;
  const androidStoreUrl = body?.android_store_url;
  const iosStoreUrl = body?.ios_store_url;

  if (
    !isValidVersion(requiredVersion) ||
    !isValidVersion(latestVersion) ||
    typeof forceUpdate !== "boolean" ||
    !isValidUrl(androidStoreUrl) ||
    !isValidUrl(iosStoreUrl)
  ) {
    return null;
  }

  return {
    required_version: requiredVersion.trim(),
    latest_version: latestVersion.trim(),
    force_update: forceUpdate,
    android_store_url: androidStoreUrl.trim(),
    ios_store_url: iosStoreUrl.trim(),
  };
}

export const getAppVersion = async (_req: Request, res: Response) => {
  try {
    const settings = await loadAppVersionSettings();

    res.set("Cache-Control", "public, max-age=300");
    res.status(200).json({
      required_version: settings.required_version,
      latest_version: settings.latest_version,
      force_update: settings.force_update,
      android_store_url: settings.android_store_url,
      ios_store_url: settings.ios_store_url,
    });
  } catch (error) {
    console.error("Error loading app version:", error);
    res.status(500).json({ message: "Failed to load app version settings" });
  }
};

export const getAppVersionSettings = async (_req: Request, res: Response) => {
  try {
    const settings = await loadAppVersionSettings();
    res.status(200).json(settings);
  } catch (error) {
    console.error("Error loading app version settings:", error);
    res.status(500).json({ message: "Failed to load app version settings" });
  }
};

export const updateAppVersionSettings = async (req: Request, res: Response) => {
  const settings = parseSettingsBody(req.body);

  if (!settings) {
    res.status(400).json({
      message:
        "Invalid settings. Check version format (e.g. 1.2.0) and store URLs (https).",
    });
    return;
  }

  try {
    const saved = await saveAppVersionSettings(settings);
    res.status(200).json({
      message: "App version settings updated successfully",
      settings: saved,
    });
  } catch (error) {
    console.error("Error saving app version settings:", error);
    res.status(500).json({
      message:
        "Failed to save settings. Ensure app_config table exists in the database.",
    });
  }
};
