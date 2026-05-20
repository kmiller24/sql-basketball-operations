/*
==================================================================================================================================================================
Ticket Sales Report

Purpose:
    - Combines the data gathered during win / loss analysis.
    - Segments ticket revenue averages into 'High', 'Medium', or 'Low'.

Threshold Logic:
    - The logic used to decide the outcomes of performance.
    - The logic can be changed to get a desired outcome. 
    - 100,000 for High Revenue: This marks the six-figure milestone, strictly isolating the top 28% of games that represent peak financial performance in the current dataset.
    - 65,000 for Low Revenue: This captures the bottom 30% of games that fall significantly below the calculated stadium average of ~88,000, identifying underperforming matchups.
    - Medium Revenue: Represents the standard "healthy" sales range, capturing the middle 42% of games that maintain consistent revenue flow.
=================================================================================================================================================================
*/
USE DataWarehouseBO
GO

-- gold.facts_ticket_sales
WITH daily_tck_revenue AS (  -- gets total ticket revenue per game
SELECT
    game_id,
    SUM(tickets_sold) AS total_tck_sold,
    SUM(ticket_revenue) AS total_tck_revenue
FROM gold.fact_ticket_sales 
GROUP BY 
    game_id
)

SELECT  
    gm.game_id,
    dtr.total_tck_sold AS tickets_sold,
    dtr.total_tck_revenue AS game_revenue,
    CASE
        WHEN total_tck_revenue >= 100000 THEN 'High'
        WHEN total_tck_revenue < 65000 THEN 'Low'
        ELSE 'Medium'
    END AS ticket_revenue_tier
FROM daily_tck_revenue AS dtr
LEFT JOIN gold.fact_games AS gm
ON dtr.game_id = gm.game_id
GROUP BY 
    gm.game_id,
    dtr.total_tck_sold,
    total_tck_revenue
ORDER BY 
    CAST(REPLACE(gm.game_id, 'game_', '')AS INT) ASC;











