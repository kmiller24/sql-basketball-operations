/*
===============================================================================
Data Exploration
===============================================================================
Purpose:
    - To explore the structure of dim tables and fact_game table.
	
===============================================================================
===============================================================================
 Understanding the volume of records associated with each category
===============================================================================
*/

 -- Group staff table by the department column to see exactly how many employees are in each area.
SELECT
    department,
    COUNT(*) AS department_count
FROM gold.dim_staff
GROUP BY department

 -- Grouping by opponent to confirm the variety and frequency of matchups.
SELECT
    opponent,
    COUNT(*) AS opponent_count
FROM gold.fact_games
GROUP BY opponent

-- Counting number of occurences for year, month and day
SELECT 
    cal_year,
    COUNT(*) AS year_occur
FROM gold.dim_date
GROUP BY cal_year

SELECT 
    cal_month,
    COUNT(*) AS month_occur
FROM gold.dim_date
GROUP BY cal_month

SELECT 
    day_name,
    COUNT(*) AS day_occur
FROM gold.dim_date
GROUP BY day_name

-- Counting wins,losses and home, away games
SELECT 
    win,
    COUNT(*) AS win_loss_occur
FROM gold.fact_games
GROUP BY win

SELECT
    home_game,
    COUNT(*) AS home_road_occur
FROM gold.fact_games
GROUP BY home_game

/*
===============================================================================
 Check for duplicates: Identify distinct entities against primary IDs. 
===============================================================================
*/

-- Audit unique player names against the id's.
SELECT
    COUNT(DISTINCT player_id) AS player_id_count,
    COUNT(DISTINCT first_name) AS first_name_count,
    COUNT(DISTINCT last_name) AS last_name_count
FROM gold.dim_player

-- Audit distinct list of staff and departments.
SELECT
    COUNT(DISTINCT role_id) AS role_id_count,
    COUNT(DISTINCT first_name) AS first_n_count,
    COUNT(DISTINCT last_name) AS last_n_count,
    COUNT(DISTINCT staff_role) AS staff_role_count,
    COUNT(DISTINCT department) AS department_count
FROM gold.dim_staff

-- Audit distinct list of opponents in game data
SELECT
    COUNT(DISTINCT game_id) AS game_id_count,
    COUNT(DISTINCT opponent) AS opponent_count
FROM gold.fact_games

/*
===============================================================================
 Search for gaps or missing information in core dimensions.
===============================================================================
*/

-- **Generic Syntax:** SELECT * FROM table_name WHERE column_name IS NULL OR column_name = '';

SELECT
    player_id,
    first_name,
    last_name,
    position,
    archetype
FROM gold.dim_player
WHERE player_id IS NULL OR first_name IS NULL OR last_name IS NULL OR position IS NULL OR archetype IS NULL
   OR player_id = '-' OR first_name = '-' OR last_name = '_' OR position = '_' OR archetype = '_'

SELECT
    role_id,
    first_name,
    last_name,
    staff_role,
    department
FROM gold.dim_staff
WHERE role_id IS NULL OR first_name IS NULL OR last_name IS NULL OR staff_role IS NULL OR department IS NULL
   OR role_id = '_' OR first_name = '_' OR last_name = '_' OR staff_role = '_' OR department = '_'

SELECT
    product_id,
    products
FROM gold.dim_products
WHERE product_id IS NULL OR products IS NULL 
   OR product_id = '_' OR products = '_'

SELECT
    opp_id,
    opponent
FROM gold.dim_opponents
WHERE opp_id IS NULL OR opponent IS NULL 
   OR opp_id = '_' OR opponent = '_'