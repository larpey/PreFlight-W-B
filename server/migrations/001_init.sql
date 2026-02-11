-- PreFlight W&B Database Schema
-- Run: psql -d preflight_wb -f migrations/001_init.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT UNIQUE NOT NULL,
  name          TEXT,
  avatar_url    TEXT,
  auth_provider TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now(),
  last_login    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE scenarios (
  id            UUID PRIMARY KEY,
  user_id       UUID REFERENCES users(id) ON DELETE CASCADE,
  aircraft_id   TEXT NOT NULL,
  name          TEXT NOT NULL,
  station_loads JSONB NOT NULL,
  fuel_loads    JSONB NOT NULL,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE magic_links (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email      TEXT NOT NULL,
  token      TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used       BOOLEAN DEFAULT false
);

CREATE INDEX idx_scenarios_user ON scenarios(user_id);
CREATE INDEX idx_scenarios_updated ON scenarios(updated_at);
CREATE INDEX idx_magic_links_token ON magic_links(token);
