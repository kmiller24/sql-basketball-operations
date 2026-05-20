/*
=================================================================================================
Win/Loss Correlation Analysis
=================================================================================================
Purpose:
    - Calculate the average revenue on "Win" days versus "Loss" days.
Instructions: 
    - Get the sum the total revenue (sales & merch) per id. 
    - Then calculate the average of those totals grouped by the Win/Loss outcome.
Outcome: Ticket Sales 
    - If the average is higher on wins, wins drives higher attendance and ticket spending.
Outcome: Merch Sales
    - If the average is higher on losses (or exactly the same),
      fan loyalty is not the primary driver for merchandise, not on-court success.  
=================================================================================================
*/
USE DataWarehouseBO
GO

-- gold.facts_ticket_sales
WITH daily_tck_revenue AS (  -- gets total ticket revenue per game
SELECT
    game_id,
    SUM(ticket_revenue) AS total_tck_revenue
FROM gold.fact_ticket_sales 
GROUP BY game_id
)
SELECT  -- gets average of total ticket revenue grouped by win_loss_flag to see if wins drive revenue
    win_loss_flag,
    AVG(total_tck_revenue) AS avg_tck_revenue
FROM daily_tck_revenue AS dtr
LEFT JOIN gold.fact_games AS gm
ON dtr.game_id = gm.game_id
WHERE gm.home_game = 1 -- filtering for home game revenue only
GROUP BY win_loss_flag


-- gold.facts_merch_sales
;WITH daily_mrc_revenue AS (  -- gets total merch revenue per game
SELECT
    sale_date,
    SUM(merch_revenue) AS total_mrc_revenue
FROM gold.fact_merch_sales 
GROUP BY sale_date
)
SELECT  -- gets average of total merch revenue grouped by win_loss_flag to see if wins drive revenue
    win_loss_flag,
    AVG(total_mrc_revenue) AS avg_mrc_revenue
FROM daily_mrc_revenue AS dmr
LEFT JOIN gold.fact_games AS gm
ON dmr.sale_date = gm.game_date
WHERE gm.home_game = 1 
GROUP BY win_loss_flag



