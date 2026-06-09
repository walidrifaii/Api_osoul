CREATE TABLE IF NOT EXISTS app_config (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  required_version TEXT NOT NULL DEFAULT '1.2.0',
  latest_version TEXT NOT NULL DEFAULT '1.2.0',
  force_update BOOLEAN NOT NULL DEFAULT TRUE,
  android_store_url TEXT NOT NULL DEFAULT 'https://play.google.com/store/apps/details?id=com.vesco.osoul',
  ios_store_url TEXT NOT NULL DEFAULT 'https://apps.apple.com/qa/app/osoul/id6747296555?l=ar',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
