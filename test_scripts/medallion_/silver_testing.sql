/* 
--------------------------------------------
1. Table Cleaning: player_data
--------------------------------------------
*/

USE DataWarehouseBO
GO

-- Checking for whitespaces
SELECT player_id FROM bronze.player_data WHERE CAST(player_id AS NVARCHAR(10)) != TRIM(CAST(player_id AS NVARCHAR(10)));
SELECT player_name FROM bronze.player_data WHERE player_name != TRIM(player_name);
SELECT position FROM bronze.player_data WHERE position != TRIM(position);
SELECT team_name FROM bronze.player_data WHERE team_name != TRIM(team_name);
SELECT minutes_avg FROM bronze.player_data WHERE CAST(minutes_avg AS NVARCHAR(10)) != TRIM(CAST(minutes_avg AS NVARCHAR(10)));
SELECT salary_millions FROM bronze.player_data WHERE CAST(salary_millions AS NVARCHAR(10)) != TRIM(CAST(salary_millions AS NVARCHAR(10)));

-- Altering Tables in silver.player_data to not accept NULL values
ALTER TABLE silver.player_data
    ALTER COLUMN player_id INT NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN position NVARCHAR(15) NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN team_name NVARCHAR(50) NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN minutes_avg FLOAT NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN salary_millions FLOAT NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN first_name NVARCHAR(50) NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN last_name NVARCHAR(50) NOT NULL;

ALTER TABLE silver.player_data
    ALTER COLUMN archetype NVARCHAR(50) NOT NULL;

/* 
--------------------------------------------
2. Table Cleaning: game_data
--------------------------------------------
*/

-- Checking for whitespaces
SELECT game_id FROM bronze.game_data WHERE CAST(game_id AS NVARCHAR(10)) != TRIM(CAST(game_id AS NVARCHAR(10)));
SELECT game_date FROM bronze.game_data WHERE CAST(game_date AS NVARCHAR(15)) != TRIM(CAST(game_date AS NVARCHAR(15)));
SELECT opponent FROM bronze.game_data WHERE opponent != TRIM(opponent);
SELECT home_game FROM bronze.game_data WHERE CAST(home_game AS NVARCHAR(5)) != TRIM(CAST(home_game AS NVARCHAR(5)));
SELECT team_score FROM bronze.game_data WHERE CAST(team_score AS NVARCHAR(5)) != TRIM(CAST(team_score AS NVARCHAR(5)));
SELECT opponent_score FROM bronze.game_data WHERE CAST(opponent_score AS NVARCHAR(5)) != TRIM(CAST(opponent_score AS NVARCHAR(5)));
SELECT win FROM bronze.game_data WHERE CAST(win AS NVARCHAR(5)) != TRIM(CAST(win AS NVARCHAR(5)));

-- Creating the point_diff and win_flag verification
SELECT 
	team_score,
	opponent_score,
	win AS win_loss,
	team_score - opponent_score AS point_diff,
	CASE 
		WHEN team_score - opponent_score  > 0 AND win = 1 THEN 'Valid Win'
		WHEN team_score - opponent_score < 0 AND win = 0 THEN 'Valid Loss'
		ELSE
			'Error: Check Data'
	END AS win_loss_flag
FROM bronze.game_data

-- Altering Tables in silver.player_data to not accept NULL values
ALTER TABLE silver.game_data
    ALTER COLUMN game_id INT NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN game_date DATE NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN opponent NVARCHAR(50) NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN home_game INT NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN team_score INT NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN opponent_score INT NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN win_loss_flag NVARCHAR(50) NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN point_diff INT NOT NULL;

ALTER TABLE silver.game_data
    ALTER COLUMN win INT NOT NULL;


/* 
--------------------------------------------
3. Table Cleaning: merch_sales
--------------------------------------------
*/

-- Checking for whitespaces
SELECT sales_id FROM silver.merch_sales WHERE CAST(sales_id AS NVARCHAR(10)) != TRIM(CAST(sales_id AS NVARCHAR(15)));
SELECT product_name FROM silver.merch_sales WHERE product_name != TRIM(product_name);
SELECT quantity FROM silver.merch_sales WHERE CAST(quantity AS NVARCHAR(15)) != TRIM(CAST(quantity AS NVARCHAR(10)));
SELECT price FROM silver.merch_sales WHERE CAST(price AS NVARCHAR(15)) != TRIM(CAST(price AS NVARCHAR(10)));
SELECT revenue FROM silver.merch_sales WHERE CAST(revenue AS NVARCHAR(15)) != TRIM(CAST(revenue AS NVARCHAR(10)));
SELECT sale_date FROM silver.merch_sales WHERE CAST(sale_date AS NVARCHAR(15)) != TRIM(CAST(sale_date AS NVARCHAR(15)));
SELECT player_id FROM silver.merch_sales WHERE CAST(player_id AS NVARCHAR(15)) != TRIM(CAST(player_id AS NVARCHAR(15)));

-- Joining merch_sales and player_data
SELECT
    ms.sales_id,
    pc.player_id,
    ms.product_name,
    ms.quantity,
    ms.price,
    ms.revenue,
    ms.sale_date
FROM bronze.merch_sales AS ms
LEFT JOIN bronze.player_data AS pc
ON ms.player_name = pc.player_name

-- Validating Revenue
SELECT
	quantity,
	price,
	revenue,
	quantity * price AS revenue_check_2
FROM silver.merch_sales

-- Altering Tables in silver.merch_sales to not accept NULL values

ALTER TABLE silver.merch_sales
    ALTER COLUMN sales_id INT NOT NULL

ALTER TABLE silver.merch_sales
    ALTER COLUMN product_name NVARCHAR(50) NOT NULL

ALTER TABLE silver.merch_sales
    ALTER COLUMN quantity INT NOT NULL

ALTER TABLE silver.merch_sales
    ALTER COLUMN price INT NOT NULL

ALTER TABLE silver.merch_sales
    ALTER COLUMN revenue INT NOT NULL

ALTER TABLE silver.merch_sales
    ALTER COLUMN sale_date DATE NOT NULL

/* 
--------------------------------------------
4. Table Cleaning: player_stats
--------------------------------------------
*/

-- creating the surrogate stats_id column
ALTER TABLE silver.player_stats
    ADD stats_id INT IDENTITY(1,1);

;WITH player_stats_insert AS (
SELECT 
    game_id,
    player_id,
    minutes_played,
    points,
    assists,
    rebounds
FROM bronze.player_stats
)

INSERT INTO silver.player_stats (
    game_id,
    player_id,
    minutes_played,
    points,
    assists,
    rebounds
)

SELECT 
    game_id,
    stats_id,
    player_id,
    minutes_played,
    points,
    assists,
    rebounds
FROM player_stats_insert

-- Checking for whitespaces
SELECT stats_id FROM silver.player_stats WHERE CAST(stats_id AS NVARCHAR(10)) != TRIM(CAST(stats_id AS NVARCHAR(10)));
SELECT player_id FROM silver.player_stats WHERE CAST(player_id AS NVARCHAR(10)) != TRIM(CAST(player_id AS NVARCHAR(10)));
SELECT minutes_played FROM silver.player_stats WHERE CAST(minutes_played AS NVARCHAR(10)) != TRIM(CAST(minutes_played AS NVARCHAR(10)));
SELECT points FROM silver.player_stats WHERE CAST(points AS NVARCHAR(10)) != TRIM(CAST(points AS NVARCHAR(10)));
SELECT assists FROM silver.player_stats WHERE CAST(assists AS NVARCHAR(10)) != TRIM(CAST(assists AS NVARCHAR(10)));
SELECT rebounds FROM silver.player_stats WHERE CAST(rebounds AS NVARCHAR(10)) != TRIM(CAST(rebounds AS NVARCHAR(10)));

-- Altering Tables in silver.player_stats to not accept NULL values

ALTER TABLE silver.player_stats
    ALTER COLUMN stats_id INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN game_id INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN player_id INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN minutes_played INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN points INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN assists INT NOT NULL

ALTER TABLE silver.player_stats
    ALTER COLUMN rebounds INT NOT NULL

/* 
--------------------------------------------
5. Table Cleaning: ticket_sales
--------------------------------------------
*/

-- Checking for whitespaces
SELECT ticket_id FROM silver.ticket_sales WHERE CAST(ticket_id AS NVARCHAR(10)) != TRIM(CAST(ticket_id AS NVARCHAR(10)));
SELECT game_id FROM silver.ticket_sales WHERE CAST(game_id AS NVARCHAR(10)) != TRIM(CAST(game_id AS NVARCHAR(10)));
SELECT tickets_sold FROM silver.ticket_sales WHERE CAST(tickets_sold AS NVARCHAR(10)) != TRIM(CAST(tickets_sold AS NVARCHAR(10)));
SELECT avg_ticket_price FROM silver.ticket_sales WHERE CAST(avg_ticket_price AS NVARCHAR(10)) != TRIM(CAST(avg_ticket_price AS NVARCHAR(10)));
SELECT revenue FROM silver.ticket_sales WHERE CAST(revenue AS NVARCHAR(10)) != TRIM(CAST(revenue AS NVARCHAR(10)));


-- creating the surrogate stats_id column
ALTER TABLE silver.ticket_sales
    ADD ticket_id INT IDENTITY(1,1) NOT NULL;

;WITH ticket_sales_data AS (
    SELECT 
        game_id,
        tickets_sold,
        avg_ticket_price,
        revenue
    FROM bronze.ticket_sales
)

INSERT INTO silver.ticket_sales (
    game_id,
    tickets_sold,
    avg_ticket_price,
    revenue
)

SELECT 
    game_id,
    tickets_sold,
    avg_ticket_price,
    revenue
FROM ticket_sales_data


--Validating Revenue
SELECT
	tickets_sold,
	avg_ticket_price,
	revenue,
	tickets_sold * avg_ticket_price AS revenue_check
FROM  silver.ticket_sales


-- Altering Tables in silver.tickets_sold to not accept NULL values

ALTER TABLE silver.ticket_sales
    ALTER COLUMN ticket_id INT NOT NULL

ALTER TABLE silver.ticket_sales
    ALTER COLUMN game_id INT NOT NULL

ALTER TABLE silver.ticket_sales
    ALTER COLUMN avg_ticket_price INT NOT NULL

ALTER TABLE silver.ticket_sales
    ALTER COLUMN revenue INT NOT NULL

ALTER TABLE silver.ticket_sales
    ALTER COLUMN revenue INT NOT NULL

ALTER TABLE silver.ticket_sales
    ALTER COLUMN ticket_id INT NOT NULL


-- Validating all revenue math
SELECT
    quantity,
    price,
    revenue,
    price * quantity AS total_revenue,
    CASE
        WHEN price * quantity = revenue THEN 'Valid'
        WHEN price * quantity != revenue THEN 'Not Valid'
        ELSE 'N/A'
    END AS validating_revenue
FROM silver.merch_sales

/* 
--------------------------------------------
6. Table Cleaning: staff_data
--------------------------------------------
*/

-- Checking for whitespaces
SELECT role_id FROM silver.staff_data WHERE CAST(role_id AS NVARCHAR(10)) != TRIM(CAST(role_id AS NVARCHAR(10)));
SELECT staff_role FROM silver.staff_data WHERE staff_role != TRIM(staff_role);
SELECT department FROM silver.staff_data WHERE department != TRIM(department);
SELECT salary FROM silver.staff_data WHERE CAST(salary AS NVARCHAR(10)) != TRIM(CAST(salary AS NVARCHAR(10)));
SELECT performance_score FROM silver.staff_data WHERE CAST(performance_score AS NVARCHAR(10)) != TRIM(CAST(performance_score AS NVARCHAR(10)));
SELECT leadership_score FROM silver.staff_data WHERE CAST(leadership_score AS NVARCHAR(10)) != TRIM(CAST(leadership_score AS NVARCHAR(10)));
SELECT experience_score FROM silver.staff_data WHERE CAST(experience_score AS NVARCHAR(10)) != TRIM(CAST(experience_score AS NVARCHAR(10)));
SELECT potential_score FROM silver.staff_data WHERE CAST(potential_score AS NVARCHAR(10)) != TRIM(CAST(potential_score AS NVARCHAR(10)));
SELECT first_name FROM silver.staff_data WHERE first_name != TRIM(first_name);
SELECT last_name FROM silver.staff_data WHERE last_name != TRIM(last_name);


-- Altering Tables in silver.staff_data to not accept NULL values

ALTER TABLE silver.staff_data
    ALTER COLUMN role_id INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN staff_role NVARCHAR(50) NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN department NVARCHAR(50) NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN salary INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN performance_score INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN leadership_score INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN experience_score INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN potential_score INT NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN first_name NVARCHAR(50) NOT NULL

ALTER TABLE silver.staff_data
    ALTER COLUMN last_name NVARCHAR(50) NOT NULL
