-- Seed Walid Rifaii — run in DbGate on the API database
-- Phone: 97431644306 → Login (not Register) → OTP via WhatsApp

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
  gen_random_uuid(),
  '97431644306',
  'individual',
  'Walid Rifaii',
  'وليد رفاعي',
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
  pending          = false;

SELECT user_id, user_phone, full_name_en, full_name_ar, pending, is_active
FROM public.users
WHERE user_phone = '97431644306';
