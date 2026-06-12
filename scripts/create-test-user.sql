-- ============================================================
-- Recreate test user (run in DbGate on production DB)
--
-- App login: phone 55551234 → Login (not Register) → OTP 1234
-- APK only: npm run android:install → open OSOUL app (not Expo Go)
--
-- Push token CANNOT be set in SQL — it is created on the phone at login.
-- Requires: mobile/google-services.json (Firebase) + npm run android:install
-- After login from the Osoul APK, run the verify query at the bottom.
-- ============================================================

-- Optional: remove old row completely (use if you deleted the account)
-- DELETE FROM public.users WHERE user_phone = '97455551234';

INSERT INTO public.users (
  user_id,
  user_phone,
  user_type,
  full_name_en,
  full_name_ar,
  is_active,
  pending,
  expo_push_token,
  push_platform
) VALUES (
  '5435765f-5693-425e-b0eb-0e5ed7cf0d4c',
  '97455551234',
  'individual',
  'Test User',
  'مستخدم تجريبي',
  true,
  false,
  NULL,
  NULL
)
ON CONFLICT (user_phone) DO UPDATE SET
  user_type        = EXCLUDED.user_type,
  full_name_en     = EXCLUDED.full_name_en,
  full_name_ar     = EXCLUDED.full_name_ar,
  is_active        = true,
  pending          = false,
  expo_push_token  = NULL,
  push_platform    = NULL;

-- Clear stale OTP rows (optional)
DELETE FROM public.otps WHERE phone = '97455551234';

-- After login on phone from OSOUL APK, you should see:
--   expo_push_token = long Firebase FCM token (NOT ExponentPushToken[...])
--   push_platform   = android
SELECT
  user_phone,
  pending,
  is_active,
  expo_push_token,
  push_platform
FROM public.users
WHERE user_phone = '97455551234';
