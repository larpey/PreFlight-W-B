-- Add Apple user ID for Sign in with Apple
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_user_id TEXT UNIQUE;
CREATE INDEX IF NOT EXISTS idx_users_apple_user_id ON users(apple_user_id);
