/*
===============================================================================
Performance Variance Analysis
===============================================================================
Purpose:
    - To compare performance or metrics of players and staff.

SQL Functions Used:
    - Window Functions: AVG() OVER() for total calculations.
===============================================================================

===============================================================================
 Evaluate staff across all evaluation scores to find "diamonds in the rough."
===============================================================================
*/

SELECT
    role_id,
    first_name,
    last_name,
    staff_role,
    department,
    -- Instructions: calculates the variance from the department average.
    -- Outcome: if scores are negative, the staff member is under performing, score lower than average
    performance_score - AVG(performance_score * 1.0) OVER(PARTITION BY department) AS prf_diff,
    leadership_score - AVG(leadership_score * 1.0) OVER(PARTITION BY department) AS lsp_diff,
    experience_score - AVG(experience_score * 1.0) OVER(PARTITION BY department) AS exp_diff,
    potential_score - AVG(potential_score * 1.0) OVER(PARTITION BY department) AS pot_diff
FROM gold.dim_staff
ORDER BY 
    CAST(REPLACE(role_id, 'stf_', '')AS INT) ASC -- converts the role_id int


/*
===============================================================================
Determine if a player is overpaid or underpaid compared to the market rate
===============================================================================
*/

SELECT
    player_id,
    first_name,
    last_name,
    position,
    archetype,
    -- Instructions:calculates if player is overpaid or underpaid compared to the average market rate for their specific position. 
    -- Outcome: If salary is negative, player is underpaid
    salary_millions - AVG(salary_millions) OVER(PARTITION BY position) AS salary_diff
FROM gold.dim_player
ORDER BY
    CAST(REPLACE(player_id, 'ply_', '')AS INT) ASC -- converts the player_id int

/*
===============================================================================
On Court Player Performance
===============================================================================
*/

SELECT
    pp.game_id,
    pl.player_id,
    pp.game_date,
    pl.first_name,
    pl.last_name,
    pl.position,
    pl.archetype,
    pl.team_name,
    -- Instructions: Measure players game stats impact against the baseline average (by position) for a specific game.
    -- Outcome: if stats are negative, the player produced less than average.
    pp.minutes_played - AVG(pp.minutes_played * 1.0) OVER(PARTITION BY pp.game_id) AS game_min_diff,
    pp.points - AVG(pp.points * 1.0) OVER(PARTITION BY pp.game_id) AS pts_diff ,
    pp.assists - AVG(pp.assists * 1.0) OVER(PARTITION BY pp.game_id) AS ast_diff,
    pp.rebounds - AVG(pp.rebounds * 1.0) OVER(PARTITION BY pp.game_id) AS reb_diff
FROM gold.fact_player_performance AS pp
LEFT JOIN gold.dim_player AS pl
ON pp.player_id = pl.player_id
ORDER BY
    CAST(REPLACE(game_id, 'game_', '')AS INT) ASC -- converts the game_id int

