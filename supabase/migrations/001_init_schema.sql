-- UnScroll D1 Database Schema (Cloudflare Workers)
-- Created: 2026-08-20
-- Database ID: ca72fab6-a375-4f0b-bea8-64aa999d29f9
-- Region: WNAM (Western North America)

-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT true
);

-- Policies table
CREATE TABLE policies (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  name TEXT NOT NULL,
  blocked_apps TEXT,
  start_time TEXT,
  end_time TEXT,
  days_of_week TEXT,
  friction_level INTEGER DEFAULT 3,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Blocked attempts table
CREATE TABLE blocked_attempts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  app_name TEXT NOT NULL,
  content_type TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  blocked BOOLEAN DEFAULT true,
  notes TEXT
);

-- Panic button events table
CREATE TABLE panic_button_events (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  activated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  cooldown_period INTEGER,
  expires_at DATETIME NOT NULL,
  acknowledged BOOLEAN DEFAULT false,
  notes TEXT
);

-- Family relationships table
CREATE TABLE family_relationships (
  id TEXT PRIMARY KEY,
  parent_id TEXT NOT NULL REFERENCES users(id),
  child_id TEXT NOT NULL REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'active'
);

-- Accountability partners table
CREATE TABLE accountability_partners (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  partner_email TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'invited'
);

-- Therapist clients table
CREATE TABLE therapist_clients (
  id TEXT PRIMARY KEY,
  therapist_id TEXT NOT NULL REFERENCES users(id),
  client_id TEXT NOT NULL REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);

-- Analytics events table
CREATE TABLE analytics_events (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  event_type TEXT NOT NULL,
  event_data TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sessions table
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  token TEXT NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
