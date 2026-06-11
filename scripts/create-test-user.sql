-- ============================================================
-- Test login user (run once in DbGate on production DB)
-- App: enter phone 55551234 → Login (not Register)
-- OTP: 1234 (fixed test code — no WhatsApp needed)
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

-- OTP row is optional: backend auto-accepts 1234 for this phone.
-- After tapping Login, you can verify immediately with 1234.
-- Only run below if you need DB OTP without the test bypass:

-- DELETE FROM public.otps WHERE phone = '97455551234';
-- (Re-login in app to regenerate OTP via API)

SELECT user_phone, pending, is_active
FROM public.users
WHERE user_phone = '97455551234';
