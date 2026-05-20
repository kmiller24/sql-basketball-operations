/*
====================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
====================================================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze ' schema from external CSV files.
	It performs the following actions:
	- Truncates the bronze tables before loading data to remove all rows from a table.. 
	- Uses the 'BULK INSERT' command to load data from scv Files to bronze tables. 

	Parameters:
		None
		This stored procedure does not accept any parameters or return any vales.

	Usage (In a new query window):
		USE DataWarehouseBO;
		GO

		EXEC bronze.load_bronze;

====================================================================================================
*/

USE DataWarehouseBO;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
		BEGIN TRY

			PRINT '=======================================';
			PRINT 'Loading Bronze Layer'
			PRINT '=======================================';

			PRINT '>> Truncating Table: bronze.game_data';
			TRUNCATE TABLE bronze.game_data;

			PRINT '>> Inserting Data Into: bronze.game_data';
			BULK INSERT bronze.game_data
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\game_data.csv'
			WITH (
				FIRSTROW = 2,				-- Skips the header row in the .csv
				FIELDTERMINATOR = ',',		-- Tells SQL that commas separate the columns
				TABLOCK						-- Locks the table during the load for faster performance
			)

			PRINT '>> Truncating Table: bronze.merch_sales';
			TRUNCATE TABLE bronze.merch_sales;

			PRINT '>> Inserting Data Into: bronze.merch_sales';
			BULK INSERT bronze.merch_sales
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\merch_sales.csv'
			WITH (
				FIRSTROW = 2,				
				FIELDTERMINATOR = ',',		
				TABLOCK						
			)

			PRINT '>> Truncating Table: bronze.player_data';
			TRUNCATE TABLE bronze.player_data;

			PRINT '>> Inserting Data Into: bronze.player_data';
			BULK INSERT bronze.player_data
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\player_data.csv'
			WITH (
				FIRSTROW = 2,				
				FIELDTERMINATOR = ',',		
				TABLOCK						
			)

			PRINT '>> Truncating Table: bronze.player_stats';
			TRUNCATE TABLE bronze.player_stats;

			PRINT '>> Inserting Data Into: bronze.player_stats';
			BULK INSERT bronze.player_stats
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\player_stats.csv'
			WITH (
				FIRSTROW = 2,				
				FIELDTERMINATOR = ',',		
				TABLOCK						
			)

			PRINT '>> Truncating Table: bronze.staff_data';
			TRUNCATE TABLE bronze.staff_data;

			PRINT '>> Inserting Data Into: bronze.staff_data';
			BULK INSERT bronze.staff_data
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\staff_data.csv'
			WITH (
				FIRSTROW = 2,				
				FIELDTERMINATOR = ',',		
				TABLOCK						
			)

			PRINT '>> Truncating Table: bronze.ticket_sales';
			TRUNCATE TABLE bronze.ticket_sales;

			PRINT '>> Inserting Data Into: bronze.ticket_sales';
			BULK INSERT bronze.ticket_sales
			FROM 'D:\User\Desktop\SQL + Tableau Projects\1. Basketball Operations\0. Project\0. Data Set\new_dataset\ticket_sales.csv'
			WITH (
				FIRSTROW = 2,				
				FIELDTERMINATOR = ',',		
				TABLOCK						
			)
	END TRY

	BEGIN CATCH
		PRINT '========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '========================================='
	END CATCH

END
GO

