USE DataWarehouseBO
GO
/*
+++++++++++++++++++++++++++
DIMENSIONS
+++++++++++++++++++++++++++
*/
-- gold.dim_player
SELECT
	player_id,
	first_name,
	last_name,
	position,
	archetype,
	team_name,
	minutes_avg,
	salary_millions
FROM silver.player_data

-- gold.dim_staff
SELECT
	role_id,
	first_name,
	last_name,
	staff_role,
	department,
	performance_score,
	leadership_score,
	experience_score,
	potential_score
FROM silver.staff_data

-- gold.dim_products

SELECT DISTINCT
	CONCAT('prd_', LEFT(product_name, 3)) AS product_id,
	product_name AS products
FROM silver.merch_sales

-- gold.dim_date 
;WITH unique_dates AS (
SELECT game_date AS activity_date FROM silver.game_data
UNION
SELECT sale_date AS activity_date FROM silver.merch_sales
)

SELECT
	activity_date,
	YEAR(activity_date)					AS calender_year,
	DATENAME(MONTH,activity_date)		AS calender_month,
	DATENAME(WEEKDAY, activity_date)	AS day_name
FROM unique_dates

/*
+++++++++++++++++++++++++++
FACTS
+++++++++++++++++++++++++++
*/

-- gold.fact_games
SELECT
	game_id,
	game_date,
	opponent,
	home_game,
	win,
	team_score,
	opponent_score,
	point_diff,
	win_loss_flag
FROM silver.game_data

-- gold.fact_ticket_sales

SELECT
	CONCAT('tkt_',ticket_id) AS ticket_id,
	gd.game_id,
	gd.game_date,
	ts.tickets_sold,
	ts.avg_ticket_price,
	ts.revenue AS ticket_revenue
FROM silver.ticket_sales AS ts
LEFT JOIN silver.game_data AS gd
ON ts.game_id = gd.game_id

-- gold.fact_merch_sales
SELECT
	CONCAT('sls_', sales_id) AS sales_id,
	CONCAT('prd_', LEFT(product_name, 3)) AS product_id,
	pd.player_id,
	ms.sale_date,
	ms.quantity,
	ms.price,
	ms.revenue
FROM silver.merch_sales AS ms
LEFT JOIN silver.player_data AS pd
ON ms.player_id = pd.player_id

-- gold.fact_player_performance
SELECT
	CONCAT('prf_', stats_id) AS prf_id,
	ps.game_id,
	ps.player_id,
	gd.game_date,
	ps.points,
	ps.assists,
	ps.rebounds,
	ps.minutes_played
FROM silver.player_stats AS ps
LEFT JOIN silver.game_data AS gd
ON ps.game_id = gd.game_id


