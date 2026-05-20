/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Figuring out what "slice of the pie" each merch category and ticket sales represents
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Merch Sales
SELECT
    pd.products,
    -- calculate how much one product contributed to the total company earnings (part-to-whole).
    SUM(merch_revenue) * 1.0 / SUM(SUM(merch_revenue)) OVER() AS merch_rev_diff
FROM gold.fact_merch_sales AS ms
LEFT JOIN gold.dim_products AS pd
ON ms.product_id = pd.product_id
GROUP BY products

-- Ticket Sales
SELECT 
    gm.opponent,
    SUM(ticket_revenue) * 1.0 / SUM(SUM(ticket_revenue)) OVER() AS tkt_rev_diff
FROM gold.fact_ticket_sales AS ts
LEFT JOIN gold.fact_games AS gm
ON ts.game_id = gm.game_id
GROUP BY opponent













