/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)
    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

USE DataWarehouseBO
GO

-- =============================================================================
-- Create Dimension: gold.dim_player
-- =============================================================================

IF OBJECT_ID('gold.dim_player', 'V') IS NOT NULL
    DROP VIEW gold.dim_player;
GO

CREATE VIEW gold.dim_player AS
SELECT 
	CONCAT('ply_', player_id) AS player_id,
	first_name,
	last_name,
	position,
	archetype,
	team_name,
	salary_millions
FROM silver.player_data
GO

-- =============================================================================
-- Create Dimension: gold.dim_staff
-- =============================================================================

IF OBJECT_ID('gold.dim_staff', 'V') IS NOT NULL
    DROP VIEW gold.dim_staff;
GO

CREATE VIEW gold.dim_staff AS
    SELECT
	CONCAT('stf_',role_id)AS role_id,
	first_name,
	last_name,
	staff_role,
	department,
	performance_score,
	leadership_score,
	experience_score,
	potential_score
FROM silver.staff_data
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT DISTINCT
	CONCAT('prd_', LEFT(LOWER(TRIM(product_name)), 3)) AS product_id,
	product_name AS products
FROM silver.merch_sales
GO

-- =============================================================================
-- Create Dimension: gold.dim_opponents
-- =============================================================================

IF OBJECT_ID('gold.dim_opponents', 'V') IS NOT NULL
    DROP VIEW gold.dim_opponents;
GO

CREATE VIEW gold.dim_opponents AS
SELECT DISTINCT
	CONCAT('opp_', LEFT(LOWER(TRIM(opponent)), 3)) AS opp_id,
	opponent
FROM silver.game_data
GO

-- =============================================================================
-- Create Dimension: gold.dim_date 
-- =============================================================================

IF OBJECT_ID('gold.dim_date','V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
WITH unique_dates AS (
	SELECT game_date AS activity_date FROM silver.game_data
	UNION
	SELECT sale_date AS activity_date FROM silver.merch_sales
)

SELECT
	activity_date,
	YEAR(activity_date)					AS cal_year,
	DATENAME(MONTH,activity_date)		AS cal_month,
	DATENAME(WEEKDAY, activity_date)	AS day_name
FROM unique_dates
GO

-- =============================================================================
-- Create Fact: gold.fact_games
-- =============================================================================

IF OBJECT_ID('gold.fact_games', 'V') IS NOT NULL
    DROP VIEW gold.fact_games;
GO

CREATE VIEW gold.fact_games AS
SELECT
	CONCAT('game_', game_id) AS game_id,
	game_date,
	opponent,
	home_game,
	win,
	team_score,
	opponent_score,
	point_diff,
	win_loss_flag
FROM silver.game_data
GO

-- =============================================================================
-- Create Fact: gold.fact_ticket_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_ticket_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_ticket_sales;
GO

CREATE VIEW gold.fact_ticket_sales AS
SELECT
	CONCAT('tkt_',ticket_id) AS ticket_id,
	CONCAT('game_', gd.game_id) AS game_id,
	gd.game_date,
	ts.tickets_sold,
	ts.avg_ticket_price,
	ts.revenue AS ticket_revenue
FROM silver.ticket_sales AS ts
LEFT JOIN silver.game_data AS gd
ON ts.game_id = gd.game_id
GO

-- =============================================================================
-- Create Fact: gold.fact_merch_sales
-- =============================================================================

IF OBJECT_ID('gold.fact_merch_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_merch_sales;
GO

CREATE VIEW gold.fact_merch_sales AS
SELECT
	CONCAT('sls_', sales_id) AS sales_id,
	CONCAT('prd_', LEFT(product_name, 3)) AS product_id,
	CONCAT('ply_',player_id) AS player_id,
	sale_date,
	quantity,
	price,
	revenue AS merch_revenue
FROM silver.merch_sales
GO

-- =============================================================================
-- Create Fact: gold.fact_player_performance
-- =============================================================================

IF OBJECT_ID('gold.fact_player_performance', 'V') IS NOT NULL
    DROP VIEW gold.fact_player_performance;
GO

CREATE VIEW gold.fact_player_performance AS
SELECT
	CONCAT('prf_', stats_id) AS prf_id,
	CONCAT('game_', ps.game_id) AS game_id,
	CONCAT('ply_',ps.player_id) AS player_id,
	gd.game_date,
	ps.minutes_played,
	ps.points,
	ps.assists,
	ps.rebounds
FROM silver.player_stats AS ps
LEFT JOIN silver.game_data AS gd
ON ps.game_id = gd.game_id
GO
