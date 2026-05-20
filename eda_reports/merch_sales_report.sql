/*
==================================================================================================================================================================
Merch Sales Report

Purpose:
    - Combines the data gathered during win / loss analysis.
    - Segments ticket revenue averages into 'High', 'Medium', or 'Low'.

Threshold Logic:
    - The logic used to decide the outcomes of performance.
    - The logic can be changed to get a desired outcome. 
    - 7,500 for High Revenue: Isolates top-performing retail days exceeding the daily average (~4,680) by over 60%, marking peak shopping surges.
    - 2,500 for Low Revenue: Flags underperforming retail days falling nearly 50% below the daily average, identifying low foot traffic dates.
    - Medium Revenue: Captures the standard daily operational baseline, representing consistent middle-range sales performance.
=================================================================================================================================================================
*/

USE DataWarehouseBO
GO

-- gold.facts_merch_sales
WITH daily_merch_revenue AS (  -- gets total merch revenue per game
SELECT
    sale_date,
    SUM(merch_revenue) AS merch_revenue
FROM gold.fact_merch_sales 
GROUP BY sale_date
)

SELECT  
    dmr.sale_date AS sale_date,
    dmr.merch_revenue AS merch_revenue,
    CASE
        WHEN merch_revenue >= 7500 THEN 'High'
        WHEN merch_revenue < 2500 THEN 'Low'
        ELSE 'Medium'
    END AS merch_sales_tier
FROM daily_merch_revenue AS dmr
LEFT JOIN gold.fact_games AS gm
ON dmr.sale_date = gm.game_date
GROUP BY 
    sale_date,
    merch_revenue
ORDER BY
    sale_date






