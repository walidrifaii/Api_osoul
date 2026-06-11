import bcrypt from "bcrypt";

export const TEST_LOGIN_PHONE = "97455551234";
export const TEST_LOGIN_OTP = "1234";

export function normalizeQatarPhone(phone: string): string {
  const digits = String(phone || "").replace(/\D/g, "");
  if (!digits) return "";
  if (digits.startsWith("974")) return digits;
  return `974${digits}`;
}

export function normalizeOtp(otp: string): string {
  return String(otp || "")
    .replace(/[\u0660-\u0669]/g, (ch) => String(ch.charCodeAt(0) - 0x0660))
    .replace(/[\u06F0-\u06F9]/g, (ch) => String(ch.charCodeAt(0) - 0x06f0))
    .replace(/\D/g, "");
}

export async function hashTestLoginOtp(): Promise<string> {
  return bcrypt.hash(TEST_LOGIN_OTP, 10);
}

export function isTestLoginPhone(phone: string): boolean {
  return normalizeQatarPhone(phone) === TEST_LOGIN_PHONE;
}
