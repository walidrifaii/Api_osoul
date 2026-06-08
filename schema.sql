-- OSOUL database schema
-- Run this in DbGate on the empty "osoul" database

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY,
  user_phone VARCHAR(20) NOT NULL UNIQUE,
  full_name_en TEXT NOT NULL,
  full_name_ar TEXT NOT NULL,
  commercial_registeration TEXT,
  company_name_en TEXT,
  company_name_ar TEXT,
  user_type VARCHAR(20) DEFAULT 'individual',
  pending BOOLEAN NOT NULL DEFAULT TRUE,
  is_active BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admins (
  admin_id UUID PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  caption TEXT NOT NULL,
  city_id INTEGER NOT NULL,
  sale_type_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  is_direct BOOLEAN NOT NULL DEFAULT FALSE,
  condition_id INTEGER NOT NULL,
  area TEXT,
  building TEXT,
  price NUMERIC,
  rooms INTEGER,
  toilets INTEGER,
  land_area INTEGER,
  images TEXT[] DEFAULT '{}',
  public_ids TEXT[] DEFAULT '{}',
  address TEXT,
  location GEOGRAPHY(POINT, 4326),
  is_featured BOOLEAN NOT NULL DEFAULT FALSE,
  viewscnt INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS saved_posts (
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, post_id)
);

CREATE TABLE IF NOT EXISTS otps (
  id SERIAL PRIMARY KEY,
  phone VARCHAR(20) NOT NULL,
  otp_hash TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_category_id ON posts(category_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_otps_phone ON otps(phone);
CREATE INDEX IF NOT EXISTS idx_otps_created_at ON otps(created_at DESC);

INSERT INTO categories (id, name) VALUES
  (1, 'Commercial'),
  (2, 'Residential'),
  (4, 'Projects'),
  (5, 'Goods'),
  (6, 'Factories'),
  (7, 'Stocks'),
  (8, 'Brands'),
  (9, 'Service'),
  (10, 'Living'),
  (11, 'Offices'),
  (12, 'Markets'),
  (13, 'Service Buildings'),
  (14, 'Service Villas'),
  (15, 'Service Lands'),
  (16, 'Stores'),
  (17, 'Apartments'),
  (18, 'Villas'),
  (19, 'Living Lands'),
  (20, 'Buildings'),
  (21, 'Chalets'),
  (22, 'Farms'),
  (23, 'Manors')
ON CONFLICT (id) DO NOTHING;
