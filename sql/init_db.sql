/*
  This script safely drops and recreates the 'master' database in PostgreSQL.
  It ensures all active connections are terminated before dropping the database.
  Then it creates the database and sets up three schemas:
    - bronze: Typically for raw data.
    - silver: Typically for cleaned and transformed data.
    - gold: Typically for business-ready and aggregated data.
  
  Usage:
    Execute this script using a PostgreSQL client such as psql.
*/

-- Step 1: Connect to the default administrative database
\c postgres

-- Step 2: Disconnect all users from the 'master' database
REVOKE CONNECT ON DATABASE "master" FROM public;
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'master';

-- Step 3: Drop and recreate the 'master' database
DROP DATABASE IF EXISTS "master";
CREATE DATABASE "master";

-- Step 4: Connect to the newly created 'master' database
\c master

-- Step 5: Create necessary schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
