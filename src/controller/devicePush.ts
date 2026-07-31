import { Request, Response } from "express";
import { pool } from "../config/dp";
import { AuthRequest } from "../middleware/protect";
import { validateAndParsePushTokenBody } from "../utils/pushTokenParsing";

export const registerDevicePushToken = async (req: Request, res: Response) => {
  const { device_id, app_version } = req.body;

  if (!device_id || typeof device_id !== "string" || !device_id.trim()) {
    res.status(400).json({ message: "device_id is required" });
    return;
  }

  const parsed = validateAndParsePushTokenBody(req.body);
  if (!parsed.ok) {
    res.status(parsed.status).json({
      message: parsed.message,
      ...(parsed.push_app_id ? { push_app_id: parsed.push_app_id } : {}),
    });
    return;
  }

  const { pushToken, platform, tokenType, environment, preferredLanguage } =
    parsed.data;

  try {
    await pool.query(
      `INSERT INTO device_push_tokens (
         device_id, push_token, push_platform, push_token_type,
         push_environment, preferred_language, app_version,
         last_opened_at, updated_at
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
       ON CONFLICT (device_id) DO UPDATE SET
         push_token = EXCLUDED.push_token,
         push_platform = EXCLUDED.push_platform,
         push_token_type = EXCLUDED.push_token_type,
         push_environment = EXCLUDED.push_environment,
         preferred_language = EXCLUDED.preferred_language,
         app_version = COALESCE(EXCLUDED.app_version, device_push_tokens.app_version),
         last_opened_at = NOW(),
         updated_at = NOW()`,
      [
        device_id.trim(),
        pushToken,
        platform,
        tokenType,
        environment,
        preferredLanguage,
        typeof app_version === "string" ? app_version.trim() : null,
      ]
    );

    res.status(200).json({
      message: "Device push token registered",
      device_id: device_id.trim(),
      push_platform: platform,
      push_token_type: tokenType,
      push_environment: environment,
      preferred_language: preferredLanguage,
    });
  } catch (error) {
    console.error(
      "Device push token registration error:",
      (error as Error).message
    );
    res.status(500).json({ message: "Failed to register device push token" });
  }
};

export const linkDeviceToUser = async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const user = authReq.user as { user_id?: string } | undefined;
  const userId = user?.user_id;
  const { device_id } = req.body;

  if (!userId) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  if (!device_id || typeof device_id !== "string" || !device_id.trim()) {
    res.status(400).json({ message: "device_id is required" });
    return;
  }

  try {
    const result = await pool.query(
      `UPDATE device_push_tokens
       SET user_id = $1, updated_at = NOW()
       WHERE device_id = $2
       RETURNING device_id`,
      [userId, device_id.trim()]
    );

    if (result.rowCount === 0) {
      res.status(404).json({ message: "Device not found" });
      return;
    }

    res.status(200).json({ message: "Device linked to user", device_id: device_id.trim() });
  } catch (error) {
    console.error("Device link error:", (error as Error).message);
    res.status(500).json({ message: "Failed to link device to user" });
  }
};

export const unlinkDeviceFromUser = async (req: Request, res: Response) => {
  const authReq = req as AuthRequest;
  const user = authReq.user as { user_id?: string } | undefined;
  const userId = user?.user_id;
  const { device_id } = req.body;

  if (!userId) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  if (!device_id || typeof device_id !== "string" || !device_id.trim()) {
    res.status(400).json({ message: "device_id is required" });
    return;
  }

  try {
    await pool.query(
      `UPDATE device_push_tokens
       SET user_id = NULL, updated_at = NOW()
       WHERE device_id = $1 AND user_id = $2`,
      [device_id.trim(), userId]
    );

    res.status(200).json({ message: "Device unlinked from user" });
  } catch (error) {
    console.error("Device unlink error:", (error as Error).message);
    res.status(500).json({ message: "Failed to unlink device from user" });
  }
};
