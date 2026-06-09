-- Run this in DbGate AFTER you tap Login and reach the OTP screen
-- Then enter OTP: 1234
-- Do NOT tap Resend OTP

DELETE FROM public.otps
WHERE phone = '97455551234';

INSERT INTO public.otps (
  phone,
  otp_hash,
  expires_at,
  used
) VALUES (
  '97455551234',
  '$2b$10$m8vjKe2XVNV06hR5Wh8Os.DQgU.O0xemhPwr3P2CpFlhAEA8xRTaa',
  NOW() + INTERVAL '24 hours',
  false
);

SELECT phone, used, expires_at > NOW() AS is_valid
FROM public.otps
WHERE phone = '97455551234'
ORDER BY created_at DESC
LIMIT 1;
