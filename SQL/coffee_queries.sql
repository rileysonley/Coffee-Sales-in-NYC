-- Create coffee_sales table --------------------
DROP TABLE IF EXISTS coffee_sales;
CREATE TABLE coffee_sales(
						  transaction_id INT,
						  transaction_date DATE,
						  transaction_time TIME,
						  transaction_qty INT,
						  store_id INT,
						  store_location VARCHAR(50),
						  product_id INT,
						  unit_price FLOAT,
						  product_category VARCHAR(50),
						  product_type VARCHAR(50),
						  product_detail VARCHAR(50)
						 )

-- Check data is imported correctly --------------------
SELECT * 
FROM coffee_sales
LIMIT 10; 

-- Find unique locations --------------------
SELECT DISTINCT store_id,
       store_location
FROM coffee_sales;

-- Branch with the highest sales --------------------
SELECT COUNT(transaction_id) AS total_sales, 
       store_location 
FROM coffee_sales
GROUP BY 2
ORDER BY 1 DESC; 

-- Find unique product_category --------------------
SELECT DISTINCT product_category
FROM coffee_sales;

-- product_category ranked by number of sales --------------------
SELECT COUNT(transaction_id) AS total_sales,
       product_category 
FROM coffee_sales
GROUP BY 2
ORDER BY 1 DESC;

-- Find unique product_type --------------------
SELECT DISTINCT product_type
FROM coffee_sales;

-- product_type ranked by number of sales --------------------
SELECT COUNT(transaction_id) AS total_sales,
       product_type
FROM coffee_sales
GROUP BY 2
ORDER BY 1 DESC;

-- Find unqie product_detail --------------------
SELECT DISTINCT product_detail 
FROM coffee_sales;

-- product_detail ranked by number of sales --------------------
SELECT COUNT(transaction_id) AS total_sales,
       product_detail 
FROM coffee_sales
GROUP BY 2
ORDER BY 1 DESC;

-- Sales by day (high to low) --------------------
SELECT date_trunc('day', transaction_date) AS day,
       COUNT(transaction_id) AS total_sales
FROM coffee_sales
GROUP BY 1
ORDER BY 2 DESC; 

-- Sales by day (low to high) --------------------
SELECT date_trunc('day', transaction_date) AS day,
       COUNT(transaction_id) AS total_sales
FROM coffee_sales
GROUP BY 1
ORDER BY 2; 

-- Sales by day for coffee vs tea --------------------
SELECT date_trunc('day', transaction_date),
       COUNT(
             CASE 
			 WHEN product_category ILIKE '%coffee%' THEN transaction_id
			 ELSE NULL
	   END) AS coffee_sales,
	   COUNT(
             CASE 
			 WHEN product_category ILIKE '%tea%' THEN transaction_id
			 ELSE NULL
	   END) AS tea_sales
FROM coffee_sales
GROUP BY 1;

-- AVG sales of coffee and tea per day -------------------
WITH t1 AS (SELECT date_trunc('day', transaction_date),
       COUNT(
             CASE 
			 WHEN product_category ILIKE '%coffee%' THEN transaction_id
			 ELSE NULL
	   END) AS coffee_sales,
	   COUNT(
             CASE 
			 WHEN product_category ILIKE '%tea%' THEN transaction_id
			 ELSE NULL
	   END) AS tea_sales
FROM coffee_sales
GROUP BY 1 )
SELECT AVG(t1.coffee_sales) AS avg_coffee_sales,
       AVG(t1.tea_sales) AS avg_tea_sales
FROM t1

-- Sales for product_category by branch -------------------
SELECT store_location,
	   product_category,
	   COUNT(transaction_id) AS total_sales
FROM coffee_sales
GROUP BY 1,2
ORDER BY 3 DESC;

-- Percentage sales of each category --------------------
WITH categorized AS (
    SELECT 
	    store_location,
        CASE 
            WHEN product_category ILIKE '%coffee%' THEN 'Coffee'
            WHEN product_category ILIKE '%tea%' THEN 'Tea'
            WHEN product_category ILIKE '%chocolate%' THEN 'Chocolate Products'
            WHEN product_category ILIKE '%branded%' THEN 'Merchandise'
            WHEN product_category ILIKE '%bakery%' THEN 'Bakery'
            WHEN product_category ILIKE '%flavours%' THEN 'Syrup'
            ELSE 'Other'
        END AS category
    FROM coffee_sales
)
SELECT 
    store_location,
	category,
    COUNT(*) AS sales,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (PARTITION BY store_location)* 100, 2) AS sales_pct
FROM categorized
GROUP BY store_location, category
ORDER BY store_location, sales_pct DESC

-- Table of product categories to export to python for transforming --------------------
SELECT date_trunc('day', transaction_date) AS day,
       store_location,
       COUNT(
             CASE 
			 WHEN product_category ILIKE '%coffee%' THEN transaction_id
			 ELSE NULL
	   END) AS coffee_sales,
	   COUNT(
             CASE 
			 WHEN product_category ILIKE '%tea%' THEN transaction_id
			 ELSE NULL
	   END) AS tea_sales,
	   COUNT(
			 CASE 
			 WHEN product_category ILIKE '%chocolate%' THEN transaction_id
			 ELSE NULL
		END) AS chocolate_product_sales,
		COUNT(
 			 CASE 
			 WHEN product_category ILIKE '%branded%' THEN transaction_id
			 ELSE NULL 
		END) AS merchandise_sales,
		COUNT(
			 CASE 
			 WHEN product_category ILIKE '%bakery%' THEN transaction_id
			 ELSE NULL
		END) AS bakery_sales,
		COUNT(
			 CASE 
			 WHEN product_category ILIKE '%flavours%' THEN transaction_id
			 ELSE NULL 
		END) AS syrup_sales
FROM coffee_sales
GROUP BY 1,2