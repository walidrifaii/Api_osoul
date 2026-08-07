-- Clear OTP rate-limit / stale codes for Walid's phone
DELETE FROM public.otps WHERE phone = '97431644306';

-- Confirm user can login (pending must be false)
SELECT user_id, user_phone, full_name_en, pending, is_active
FROM public.users
WHERE user_phone = '97431644306';
