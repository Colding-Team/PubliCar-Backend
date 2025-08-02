-- Add password column to users table
ALTER TABLE users ADD COLUMN password_hash TEXT;

-- Add comment to document the column
COMMENT ON COLUMN users.password_hash IS 'Hashed password for user authentication';
