/*
==========================================================================================================================================================================
Player Report

Purpose:
    - Combines the data gathered during player performance analysis.
    - Consolidates game-by-game impact into a single seasonal player profile.
    - Segments players by financial and performance tiers.

Threshold Logic:
    - The logic used to decide the outcomes of performance and finance. 
    - The logic can be changed to get a desired outcome. 
    - +/- 2.0 for Salary: Uses a $2 million buffer from the positional average to flag strictly overpaid or bargain contracts.
    - +15.0 for Points: Isolates elite offensive players who score 15 points above the nightly average.
    - +5.0 for Minutes: Separates heavy rotation players and starters from standard bench players.
    - 0 for Points, Assists, and Rebounds: Represents the baseline average. Used to flag players who contribute strictly above the league average in specific categories.
=========================================================================================================================================================================
*/
USE DataWarehouseBO
GO

-- STEP 1: Calculate the variance for every single game played
WITH nightly_game_variances AS (
    SELECT
        pp.player_id,
        pp.game_id,
        pl.first_name,
        pl.last_name,
        pl.position,
        pl.archetype,
        pl.team_name,
        pl.salary_millions,
        pp.minutes_played,
        pp.points,
        pp.assists,
        pp.rebounds,
        -- Nightly performance variance: Measure averages of players game stats impact against across the entire season.
        pp.minutes_played - AVG(pp.minutes_played * 1.0) OVER(PARTITION BY pp.game_id) AS game_min_var, -- 1.0 is used to get a decimal (float) value
        pp.points - AVG(pp.points * 1.0) OVER(PARTITION BY pp.game_id) AS pts_var,
        pp.assists - AVG(pp.assists * 1.0) OVER(PARTITION BY pp.game_id) AS ast_var,
        pp.rebounds - AVG(pp.rebounds * 1.0) OVER(PARTITION BY pp.game_id) AS reb_var
    FROM gold.dim_player AS pl
    LEFT JOIN gold.fact_player_performance AS pp 
    ON pl.player_id = pp.player_id
),
-- STEP 2: Collapse nightly stat variances into a single row per player using seasonal averages
seasonal_averages AS (
    SELECT
        player_id,
        first_name,
        last_name,
        position,
        archetype,
        team_name,
        salary_millions,
        -- Stat averages per player over the entire season
        AVG(minutes_played * 1.0) AS avg_minutes,
        AVG(points * 1.0) AS avg_points,
        AVG(assists * 1.0) AS avg_assists,
        AVG(rebounds * 1.0) AS avg_rebounds,
        -- Financial: Calculate once per player based on positional average
        MAX(salary_millions) - AVG(MAX(salary_millions)) OVER(PARTITION BY position) AS salary_diff,
        -- Performance: Average the nightly variances to find the seasonal trend
        AVG(game_min_var) AS avg_game_min_diff,
        AVG(pts_var) AS avg_pts_diff,
        AVG(ast_var) AS avg_ast_diff,
        AVG(reb_var) AS avg_reb_diff
    FROM nightly_game_variances
    GROUP BY 
        player_id, 
        first_name, 
        last_name, 
        position, 
        archetype, 
        team_name,
        salary_millions
),


-- STEP 3: Apply the Tier labels to the final seasonal metrics
final_player_report AS (
SELECT 
    player_id,
    first_name,
    last_name,
    position,
    archetype,
    team_name,
    salary_millions,
    avg_minutes,
    avg_points,
    avg_assists,
    avg_rebounds,
    avg_game_min_diff,
    avg_pts_diff,
    avg_ast_diff,
    avg_reb_diff,
    -- Financial Tier (using 2.0 buffer) ($2 million) as threshold buffer average salary difference, ensures that a player has to be significantly away from the positional average.
    CASE
        WHEN salary_diff > 2.0 THEN 'Overpaid'
        WHEN salary_diff < -2.0 THEN 'Bargain'
        ELSE 'Market Value'
    END AS financial_tier,

    -- Performance Tier using 15.0 (points) threshold buffer for Elite and 5.0 for Starter time using seasonal averages.
    CASE
        WHEN avg_pts_diff > 15.0 AND avg_game_min_diff > 5.0 THEN 'Elite'
        WHEN avg_pts_diff > 5.0 AND avg_game_min_diff > 5.0 THEN 'Star'
        WHEN avg_game_min_diff > 5.0 THEN 'Starter'
        WHEN avg_game_min_diff < 5.0 AND (avg_ast_diff > 0 OR avg_reb_diff > 0) THEN 'Role Player'
        ELSE 'Bench'
    END AS performance_tier
FROM seasonal_averages
)


SELECT 
    player_id,
    first_name, 
    last_name, 
    position, 
    archetype, 
    team_name,
    salary_millions,
    CAST(avg_minutes AS FLOAT) AS avg_minutes, 
    CAST(avg_points AS FLOAT) AS avg_points, 
    CAST(avg_assists AS FLOAT)AS avg_assists,
    CAST(avg_rebounds AS FLOAT) AS avg_rebounds,
    CAST(ROUND(avg_game_min_diff, 2) AS FLOAT) avg_game_min_diff,
    CAST(ROUND(avg_pts_diff, 2) AS FLOAT) AS avg_pts_diff,
    CAST(ROUND(avg_ast_diff, 2) AS FLOAT) AS avg_ast_diff,
    CAST(ROUND(avg_reb_diff, 2) AS FLOAT) AS avg_reb_diff,
    financial_tier,
    performance_tier,
    CASE 
        -- Trade Logic: High pay, low output
        WHEN financial_tier = 'Overpaid' AND performance_tier IN ('Bench', 'Role Player') THEN 'Immediate Trade'
        WHEN financial_tier = 'Market_Value' AND performance_tier = 'Bench' THEN 'Consider Trade'
        -- Fit Logic: Low pay / market value, decent output
        WHEN financial_tier IN ('Bargain', 'Market_Value') AND performance_tier = 'Starter' THEN 'Good Fit'
        -- Retention Logic: Pay matches play
        WHEN performance_tier = 'Elite' THEN 'Core Piece'
        WHEN performance_tier = 'Star' THEN 'Good Piece'
        ELSE 'Monitor Perfomance'
    END AS roster_actions
FROM final_player_report
ORDER BY 
    CAST(REPLACE(player_id, 'ply_', '')AS INT) ASC, -- converts the player_id int 
    first_name, 
    last_name, 
    position, 
    archetype, 
    team_name,
    salary_millions,
    avg_minutes, 
    avg_points, 
    avg_assists,
    avg_rebounds,
    avg_game_min_diff,
    avg_pts_diff,
    avg_ast_diff,
    avg_reb_diff,
    financial_tier,
    performance_tier