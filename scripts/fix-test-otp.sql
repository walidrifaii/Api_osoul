-- ============================================================
-- Test login OTP fix for DbGate (production DB)
--
-- App login phone: 55551234   (8 digits only, app adds 974)
-- DB phone stored as: 97455551234
-- OTP to enter in app: 1234
--
-- IMPORTANT: Mobile app uses production API:
-- https://amctag-api-osoul.38f0fz.easypanel.host
-- Run this script on THAT production database in DbGate (not local DB).
--
-- Easier option: deploy latest backend code, then login with 55551234
-- and OTP 1234 works automatically (no DbGate needed).
--
-- Manual DbGate steps:
-- 1) Run create-test-user.sql ONCE (if user does not exist)
-- 2) In app: enter 55551234 and tap Login
-- 3) Wait until OTP screen appears
-- 4) Run THIS script in DbGate on production DB
-- 5) Enter OTP 1234 in app
--    Do NOT tap Resend OTP
-- ============================================================

-- Ensure test user exists and can login
INSERT INTO public.users (
  user_id,
  user_phone,
  user_type,
  full_name_en,
  full_name_ar,
  is_active,
  pending
) VALUES (
  '5435765f-5693-425e-b0eb-0e5ed7cf0d4c',
  '97455551234',
  'individual',
  'Test User',
  'مستخدم تجريبي',
  true,
  false
)
ON CONFLICT (user_phone) DO UPDATE SET
  is_active = true,
  pending = false,
  updated_at = CURRENT_TIMESTAMP;

-- Replace any OTP created by login/resend with fixed test OTP
DELETE FROM public.otps
WHERE phone = '97455551234';

INSERT INTO public.otps (
  phone,
  otp_hash,
  expires_at,
  used
) VALUES (
  '97455551234',
  '$2b$10$DXlefH0jdL0d24BZy1R0gek4KvBOz1p0hxAVxbfiTdd7OlJYC9/Pe',
  NOW() + INTERVAL '24 hours',
  false
);

-- Should return: used=false, is_valid=true
SELECT
  phone,
  used,
  expires_at,
  expires_at > NOW() AS is_valid
FROM public.otps
WHERE phone = '97455551234'
ORDER BY created_at DESC
LIMIT 1;
