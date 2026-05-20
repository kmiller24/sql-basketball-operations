/*
==================================================================================================================================================================
Games Performance

Purpose:
    - Establish "Target" thresholds for core metrics to inform future Red/Green conditional formatting in Tableau..

Threshold Logic:
    - Green if the team scores greater than or equal to 115 points.
    - Red if the team scores less than or equal to 100 points.
    - Yellow for any points score that doesnt fall in the green or red range. 
    
=================================================================================================================================================================
*/
USE DataWarehouseBO
GO

-- SELECT * FROM gold.fact_games

SELECT
    game_id,
    game_date,
    opponent,
    home_game,
    team_score,
    opponent_score,
    point_diff,
    win,
    win_loss_flag,
    CASE 
        WHEN team_score >= 115 THEN 'Green'
        WHEN team_score <= 100 THEN 'Red'
        ELSE 'Yellow'
    END AS points_kpi
FROM gold.fact_games
ORDER BY 
    CAST(REPLACE(game_id, 'game_', '')AS INT) ASC,
    game_date