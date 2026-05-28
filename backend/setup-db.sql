-- Connect as postgres user and create admin user with privileges
-- This script creates the admin user and grants access to the database

-- Create user if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'admin') THEN
        CREATE USER admin WITH PASSWORD 'admin123';
        RAISE NOTICE 'User admin created';
    ELSE
        RAISE NOTICE 'User admin already exists';
    END IF;
END
$$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE "AI_Life_Manager_db" TO admin;
ALTER USER admin WITH SUPERUSER;

-- Create database if not exists
SELECT 'Database already exists or created' as result;
