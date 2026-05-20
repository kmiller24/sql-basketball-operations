/*
==========================================
CREATE DATABASE AND SCHEMAS
==========================================
Script Purpose:
	This script creats a new database name 'DataWarehouseBO' after checking if it already exists.
	If the database exists, it is dropped recreated. Additionally, the script sets up three schemas within the databaseL 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouseBO' database if it exists.
	All data in the database will be permanently deleted. 
	Proced with caution and ensure you have proper backups before running this script.
*/


USE master;
GO

-- Drop and recreate the 'DataWarehouseBO' database if it already exists

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseBO')
BEGIN
	ALTER DATABASE DataWarehouseBO SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- changes access mode of database, ensures that only one person (the administrator) can be connected at a time.
	DROP DATABASE DataWarehouseBO
END;
GO

-- Create Database DataWarehouseBO

CREATE DATABASE DataWarehouseBO;
GO

USE DataWarehouseBO;
GO

-- Create Schema's

CREATE SCHEMA bronze;
GO 
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
GO 