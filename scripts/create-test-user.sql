-- ============================================================
-- STEP 1: Run this ONCE in DbGate to create the test user
-- Phone: 97455551234
-- ============================================================

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
  user_type     = EXCLUDED.user_type,
  full_name_en  = EXCLUDED.full_name_en,
  full_name_ar  = EXCLUDED.full_name_ar,
  is_active     = true,
  pending       = false,
  updated_at    = CURRENT_TIMESTAMP;

-- ============================================================
-- STEP 2: In the app, enter phone 55551234 and tap LOGIN
--         (wait until OTP screen appears)
--
-- STEP 3: Run ONLY the block below in DbGate, then enter OTP 1234
--         Do NOT tap "Resend OTP"
-- ============================================================

DELETE FROM public.otps
WHERE phone = '97455551234';

INSERT INTO public.otps (
  phone,
  otp_hash,
  expires_at,
  used
) VALUES (
  '97455551234',
  '$2b$10$Ku93lIMkOBBRnO9/.HnG4evTZ8qtdZo6PWAvJPa2aW5opwPkzVhpe',
  NOW() + INTERVAL '24 hours',
  false
);

-- Check OTP is ready
SELECT phone, used, expires_at > NOW() AS is_valid
FROM public.otps
WHERE phone = '97455551234'
ORDER BY created_at DESC
LIMIT 1;
