
/*
===============================================================================
Alter Tables & Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    The stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
        - Alters Silver Tables.
		- Truncates Silver Tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	This stored procedure does not accept any parameters or return any values.

===============================================================================
STAGE 1: ALTER TABLES - ONE TIME SETUP (RUN ONLY ONCE, BEFORE STAGE 2)
    Usuage Explanation: If the column does not exist, create it. 
===============================================================================
*/

USE DataWarehouseBO
GO

-- PLAYER DATA
IF COL_LENGTH('silver.player_data', 'player_name') IS NOT NULL
BEGIN
    ALTER TABLE silver.player_data DROP COLUMN player_name;
END

IF COL_LENGTH('silver.player_data', 'first_name') IS NULL
BEGIN
    ALTER TABLE silver.player_data ADD first_name NVARCHAR(50) NOT NULL;
END

IF COL_LENGTH('silver.player_data', 'last_name') IS NULL
BEGIN
    ALTER TABLE silver.player_data ADD last_name NVARCHAR(50) NOT NULL;
END

IF COL_LENGTH('silver.player_data', 'archetype') IS NULL
BEGIN
    ALTER TABLE silver.player_data ADD archetype NVARCHAR(50) NOT NULL;
END

-- drops static minutes_avg column
ALTER TABLE silver.player_data DROP COLUMN minutes_avg;

SELECT * FROM silver.player_data

-- GAME DATA
IF COL_LENGTH('silver.game_data', 'win_loss_flag') IS NULL
BEGIN
    ALTER TABLE silver.game_data ADD win_loss_flag NVARCHAR(50) NOT NULL;
END

IF COL_LENGTH('silver.game_data', 'point_diff') IS NULL
BEGIN
    ALTER TABLE silver.game_data ADD point_diff INT NOT NULL;
END


-- MERCH SALES
IF COL_LENGTH('silver.merch_sales', 'player_id') IS NULL
BEGIN
    ALTER TABLE silver.merch_sales ADD player_id INT NOT NULL;
END

IF COL_LENGTH('silver.merch_sales', 'player_name') IS NOT NULL
BEGIN
    ALTER TABLE silver.merch_sales DROP COLUMN player_name;
END


-- PLAYER STATS
IF COL_LENGTH('silver.player_stats', 'stats_id') IS NULL
BEGIN
    ALTER TABLE silver.player_stats ADD stats_id INT IDENTITY(1,1) NOT NULL;
END


-- TICKET SALES
IF COL_LENGTH('silver.ticket_sales', 'ticket_id') IS NULL
BEGIN
    ALTER TABLE silver.ticket_sales ADD ticket_id INT IDENTITY(1,1) NOT NULL;
END


-- STAFF DATA
IF COL_LENGTH('silver.staff_data', 'role_id') IS NULL
BEGIN
    ALTER TABLE silver.staff_data ADD role_id INT IDENTITY(1,1) NOT NULL;
END

IF COL_LENGTH('silver.staff_data', 'first_name') IS NULL
BEGIN
    ALTER TABLE silver.staff_data ADD first_name NVARCHAR(50) NOT NULL;
END

IF COL_LENGTH('silver.staff_data', 'last_name') IS NULL
BEGIN
    ALTER TABLE silver.staff_data ADD last_name NVARCHAR(50) NOT NULL;
END
GO

/*
===============================================================================
STAGE 2: STORED PROCEDURES (REUSABLE)
==============================================================================
Usage Example:
    USE DataWarehouseBO
    GO

    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    BEGIN TRY

        -- RESET TABLES: ensures empty tables before cleaned data is inserted. 
        TRUNCATE TABLE silver.game_data;
        TRUNCATE TABLE silver.player_data;
        TRUNCATE TABLE silver.staff_data;
        TRUNCATE TABLE silver.player_stats;
        TRUNCATE TABLE silver.merch_sales;
        TRUNCATE TABLE silver.ticket_sales;

        -- =========================
        -- PLAYER DATA
        -- =========================
        ;WITH player_transform AS (
            SELECT
                player_id,

                CASE player_name
                    WHEN 'Player_1' THEN 'Jordan'
                    WHEN 'Player_2' THEN 'Elias'
                    WHEN 'Player_3' THEN 'Xavier'
                    WHEN 'Player_4' THEN 'Jace'
                    WHEN 'Player_5' THEN 'Malachi'
                    WHEN 'Player_6' THEN 'Silas'
                    WHEN 'Player_7' THEN 'Donovan'
                    WHEN 'Player_8' THEN 'Quentin'
                    WHEN 'Player_9' THEN 'Cassian'
                    WHEN 'Player_10' THEN 'Luka'
                    WHEN 'Player_11' THEN 'Zion'
                    WHEN 'Player_12' THEN 'Kael'
                    WHEN 'Player_13' THEN 'Julian'
                    WHEN 'Player_14' THEN 'Victor'
                    WHEN 'Player_15' THEN 'Adrian'
                END AS first_name,

                CASE player_name
                    WHEN 'Player_1' THEN 'Marcus'
                    WHEN 'Player_2' THEN 'Thorne'
                    WHEN 'Player_3' THEN 'Reed'
                    WHEN 'Player_4' THEN 'Sterling'
                    WHEN 'Player_5' THEN 'Webb'
                    WHEN 'Player_6' THEN 'Vance'
                    WHEN 'Player_7' THEN 'Hayes'
                    WHEN 'Player_8' THEN 'Rivers'
                    WHEN 'Player_9' THEN 'Brooks'
                    WHEN 'Player_10' THEN 'Bennett'
                    WHEN 'Player_11' THEN 'Miller'
                    WHEN 'Player_12' THEN 'Grayson'
                    WHEN 'Player_13' THEN 'Pierce'
                    WHEN 'Player_14' THEN 'Stone'
                    WHEN 'Player_15' THEN 'Knight'
                END AS last_name,

                position,

                CASE 
                    WHEN team_name = 'Archers' THEN 'St. Louis Archers'
                    ELSE team_name
                END AS team_name,

                CASE player_name
                    WHEN 'Player_1' THEN 'Sharpshooter'
                    WHEN 'Player_2' THEN 'Glass Defender'
                    WHEN 'Player_3' THEN 'Lockdown Defender'
                    WHEN 'Player_4' THEN 'Shot Creator'
                    WHEN 'Player_5' THEN 'Glass Defender'
                    WHEN 'Player_6' THEN 'Slasher'
                    WHEN 'Player_7' THEN 'Playmaker'
                    WHEN 'Player_8' THEN 'Slasher'
                    WHEN 'Player_9' THEN 'Lockdown Defender'
                    WHEN 'Player_10' THEN 'Playmaker'
                    WHEN 'Player_11' THEN 'Sharpshooter'
                    WHEN 'Player_12' THEN 'Playmaker'
                    WHEN 'Player_13' THEN 'Glass Defender'
                    WHEN 'Player_14' THEN 'Shot Creator'
                    WHEN 'Player_15' THEN 'Lockdown Defender'
                END AS archetype,

                minutes_avg,
                salary_millions
            FROM bronze.player_data
        )

        INSERT INTO silver.player_data (
            player_id,
            first_name,
            last_name,
            position,
            team_name,
            archetype,
            minutes_avg,
            salary_millions
        )
        SELECT 
            player_id,
            first_name,
            last_name,
            position,
            team_name,
            archetype,
            minutes_avg,
            salary_millions
        FROM player_transform;


        -- =========================
        -- GAME DATA
        -- =========================
        ;WITH game_transform AS (
            SELECT
                game_id,
                game_date,
                opponent,
                home_game,
                team_score,
                opponent_score,
                team_score - opponent_score AS point_diff,

                CASE 
                    WHEN team_score > opponent_score THEN 'Win'
                    ELSE 'Loss'
                END AS win_loss_flag,

                CASE 
                    WHEN team_score > opponent_score THEN 1 ELSE 0
                END AS win
            FROM bronze.game_data
        )

        INSERT INTO silver.game_data (
            game_id,
            game_date,
            opponent,
            home_game,
            team_score,
            opponent_score,
            point_diff,
            win_loss_flag,
            win
        )
        SELECT 
            game_id,
            game_date,
            opponent,
            home_game,
            team_score,
            opponent_score,
            point_diff,
            win_loss_flag,
            win
        FROM game_transform;


        -- =========================
        -- MERCH SALES
        -- =========================
        ;WITH merch_transform AS (
            SELECT
                ms.sales_id,
                pd.player_id,
                ms.product_name,
                ms.quantity,
                ms.price,
                ms.revenue,
                ms.sale_date
            FROM bronze.merch_sales ms
            LEFT JOIN bronze.player_data pd
                ON ms.player_name = pd.player_name
        )

        INSERT INTO silver.merch_sales (
            sales_id,
            player_id,
            product_name,
            quantity,
            price,
            revenue,
            sale_date
        )
        SELECT 
            sales_id,
            player_id,
            product_name,
            quantity,
            price,
            revenue,
            sale_date
        FROM merch_transform;


        -- =========================
        -- PLAYER STATS
        -- =========================
        INSERT INTO silver.player_stats (
            game_id,
            player_id,
            minutes_played,
            points,
            assists,
            rebounds
        )
        SELECT 
            game_id,
            player_id,
            minutes_played,
            points,
            assists,
            rebounds
        FROM bronze.player_stats;


        -- =========================
        -- TICKET SALES
        -- =========================
        INSERT INTO silver.ticket_sales (
            game_id,
            tickets_sold,
            avg_ticket_price,
            revenue
        )
        SELECT 
            game_id,
            tickets_sold,
            avg_ticket_price,
            revenue
        FROM bronze.ticket_sales;


        -- =========================
        -- STAFF DATA
        -- =========================
        ;WITH staff_transform AS (
            SELECT
                staff_role,

                CASE staff_role
                    WHEN 'General Manager' THEN 'Alistair'
                    WHEN 'Assistant GM' THEN 'Bernard'
                    WHEN 'Director of Analytics' THEN 'Cedric'
                    WHEN 'Head Scout' THEN 'Dexter'
                    WHEN 'Salary Cap Specialist' THEN 'Everett'
                    WHEN 'Head Coach' THEN 'Franklin'
                    WHEN 'Assistant Coach 1' THEN 'Graham'
                    WHEN 'Assistant Coach 2' THEN 'Harrison'
                    WHEN 'Player Development Coach' THEN 'Isaac'
                    WHEN 'Strength & Conditioning Coach' THEN 'Jasper'
                    WHEN 'Team Trainer' THEN 'Kenneth'
                END AS first_name,

                CASE staff_role
                    WHEN 'General Manager' THEN 'Finch'
                    WHEN 'Assistant GM' THEN 'Shaw'
                    WHEN 'Director of Analytics' THEN 'Ward'
                    WHEN 'Head Scout' THEN 'Moore'
                    WHEN 'Salary Cap Specialist' THEN 'Hale'
                    WHEN 'Head Coach' THEN 'Frost'
                    WHEN 'Assistant Coach 1' THEN 'Nash'
                    WHEN 'Assistant Coach 2' THEN 'Wells'
                    WHEN 'Player Development Coach' THEN 'Clark'
                    WHEN 'Strength & Conditioning Coach' THEN 'Johns'
                    WHEN 'Team Trainer' THEN 'Wright'
                END AS last_name,

                department,
                salary,
                performance_score,
                leadership_score,
                experience_score,
                potential_score
            FROM bronze.staff_data
        )

        INSERT INTO silver.staff_data (
            staff_role,
            first_name,
            last_name,
            department,
            salary,
            performance_score,
            leadership_score,
            experience_score,
            potential_score
        )
        SELECT 
            staff_role,
            first_name,
            last_name,
            department,
            salary,
            performance_score,
            leadership_score,
            experience_score,
            potential_score
        FROM staff_transform;
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