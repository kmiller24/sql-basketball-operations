/*
===============================================================================
Measures Exploration
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), DATEDIFF()
===============================================================================

===============================================================================
 Find the start and end dates to establish the analysis period
===============================================================================
*/

-- Determine exactly what season or timeframe you are acting as GM.

-- Operational Dates: game/ticket sales (basketball season)(gold.fact_ticket_sales also has game_date column)
SELECT
    MIN(game_date) min_date,
    MAX(game_date) max_date
FROM gold.fact_games

-- Event Dates: merch sales 

SELECT
    MIN(sale_date) min_date,
    MAX(sale_date) max_date 
FROM gold.fact_merch_sales

-- game and merch dates combined
SELECT 
    MIN(activity_date) min_date,
    MAX(activity_date) max_date
FROM gold.dim_date

/*
===============================================================================
Game Analysis: find highest/lowers scoring games and avg game revenue
===============================================================================
*/

SELECT
    MIN(team_score) AS min_score,
    MAX(team_score) AS max_score
FROM gold.fact_games

SELECT
    AVG(ticket_revenue) AS avg_season_revenue --avg revenue for the entire season
FROM gold.fact_ticket_sales

/*
===============================================================================
 Calculate season durations
===============================================================================
*/

SELECT
    DATEDIFF(day, MIN(game_date), MAX(game_date)) AS season_days
FROM gold.fact_games

/*
===============================================================================
 Calculate total attendance 
===============================================================================
*/

SELECT SUM(tickets_sold) AS total_attendance FROM gold.fact_ticket_sales

/*
==========================================================================================================================
KPI Benchmark: Establish "Target" thresholds for core metrics to inform future Red/Green conditional formatting in Tableau.
==========================================================================================================================
*/

SELECT
    team_score,
    CASE 
        WHEN team_score >= 115 THEN 'Green'
        WHEN team_score <= 100 THEN 'Red'
        ELSE 'Yellow'
    END point_kpi
FROM gold.fact_games

/*
==========================================================================================================================
Player Contracts: Establish the financial baseline for the player roster
==========================================================================================================================
*/

SELECT * FROM gold.dim_player
SELECT
    ROUND(AVG(salary_millions), 2) avg_salary,
    MIN(salary_millions) min_salary,
    MAX(salary_millions) max_salary
FROM gold.dim_player




