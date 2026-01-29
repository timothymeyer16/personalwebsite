-- Create Local Development Database
-- Run this script in SSMS connected to (localdb)\MSSQLLocalDB

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'PersonalWebsiteDb')
BEGIN
    CREATE DATABASE PersonalWebsiteDb;
    PRINT 'Database PersonalWebsiteDb created successfully.';
END
ELSE
BEGIN
    PRINT 'Database PersonalWebsiteDb already exists.';
END
GO

USE PersonalWebsiteDb;
GO

PRINT 'Database setup complete. Run EF Core migrations to create tables.';
GO
