/*
====================================================================================================
DDL Script: Create Bronze Tables
====================================================================================================
Script Purpose:
	This script creates tables in the 'bronze' schema, dropping existing tables if they already exists. 
	Run this script to re-define the DDL structure of 'bronze' Tables
====================================================================================================
*/

USE DataWarehouseBO;
GO

-- Source: Excel .csv

IF OBJECT_ID ('bronze.game_data') IS NOT NULL
	DROP TABLE bronze.game_data
CREATE TABLE bronze.game_data (
	game_id INT,
	game_date DATE,
	opponent NVARCHAR(50),
	home_game INT,
	team_score INT,
	opponent_score INT,
	win INT

)
GO

IF OBJECT_ID ('bronze.merch_sales') IS NOT NULL
	DROP TABLE bronze.merch_sales
CREATE TABLE bronze.merch_sales (
	sales_id INT,
	product_name NVARCHAR(50),
	player_name NVARCHAR(50),
	quantity INT,
	price INT,
	revenue INT, 
	sale_date DATE
)
GO

IF OBJECT_ID ('bronze.player_data') IS NOT NULL
	DROP TABLE bronze.player_data
CREATE TABLE bronze.player_data (
	player_id INT,
	player_name NVARCHAR(50),
	position NVARCHAR(15),
	team_name NVARCHAR(50),
	minutes_avg FLOAT,
	salary_millions FLOAT

)
GO

IF OBJECT_ID ('bronze.player_stats') IS NOT NULL
	DROP TABLE bronze.player_stats
CREATE TABLE bronze.player_stats (
	game_id INT,
	player_id INT,
	minutes_played INT,
	points INT,
	assists INT,
	rebounds INT,
)
GO

IF OBJECT_ID ('bronze.staff_data') IS NOT NULL
	DROP TABLE bronze.staff_data
CREATE TABLE bronze.staff_data (
	staff_role NVARCHAR(50),
	department NVARCHAR(50),
	salary INT,
	performance_score INT,
	leadership_score INT,
	experience_score INT,
	potential_score INT

)
GO

IF OBJECT_ID ('bronze.ticket_sales') IS NOT NULL
	DROP TABLE bronze.ticket_sales
CREATE TABLE bronze.ticket_sales (
	game_id INT,
	tickets_sold INT,
	avg_ticket_price INT,
	revenue INT
)
GO

