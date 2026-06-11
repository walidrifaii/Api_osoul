export const TEST_LOGIN_PHONE = "97455551234";
export const TEST_LOGIN_OTP = "1234";
export const TEST_LOGIN_OTP_HASH =
  "$2b$10$Ku93lIMkOBBRnO9/.HnG4evTZ8qtdZo6PWAvJPa2aW5opwPkzVhpe";

export function normalizeQatarPhone(phone: string): string {
  const digits = String(phone || "").replace(/\D/g, "");
  if (!digits) return "";
  if (digits.startsWith("974")) return digits;
  return `974${digits}`;
}

export function isTestLoginPhone(phone: string): boolean {
  return normalizeQatarPhone(phone) === TEST_LOGIN_PHONE;
}
