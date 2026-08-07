CREATE TABLE IF NOT EXISTS device_push_tokens (
  device_id TEXT PRIMARY KEY,
  push_token TEXT NOT NULL,
  push_platform TEXT,
  push_token_type TEXT,
  push_environment TEXT,
  preferred_language TEXT DEFAULT 'ar',
  user_id TEXT REFERENCES users(user_id) ON DELETE SET NULL,
  app_version TEXT,
  last_opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_device_push_tokens_push_token
  ON device_push_tokens (push_token);

CREATE INDEX IF NOT EXISTS idx_device_push_tokens_user_id
  ON device_push_tokens (user_id);
