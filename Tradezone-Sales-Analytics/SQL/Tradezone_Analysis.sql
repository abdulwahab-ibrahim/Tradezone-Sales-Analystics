SELECT *
FROM customers;

SELECT *
FROM order_items;

SELECT *
FROM orders;

SELECT *
FROM payments;

SELECT *
FROM products;

SELECT *
FROM reviews;

SELECT *
FROM sellers;


--------------- DATA CLEANING 
------- REMOVE DUPLICATE
---- FOR CUSTOMERS
SELECT *
FROM Customers;

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id 
HAVING COUNT(*) > 1
ORDER BY customer_id ASC;

---- FOR ORDER ITEMS
SELECT *
FROM order_items;

SELECT item_id, COUNT(*) 
FROM order_items
GROUP BY item_id
HAVING COUNT(*) > 1;

---- FOR ORDERS
SELECT *
FROM orders;

SELECT order_id, COUNT(*) 
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

---- FOR PAYMENTS
SELECT *
FROM payments;

SELECT payment_id, COUNT(*) 
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

---- FOR PRODUCTS
SELECT *
FROM products;

SELECT product_id, COUNT(*) 
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM products
WHERE unit_price < 0;

-- Product Price Validation
-- Checked for negative product prices.
-- No invalid prices found.

---- FOR REVIEWS
SELECT *
FROM reviews;

SELECT review_id, COUNT(*) 
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT *
FROM reviews
WHERE rating < 1 OR rating > 5;

SELECT COUNT(*)
FROM reviews
WHERE rating < 1 OR rating > 5;

DELETE FROM reviews
WHERE rating < 1 OR rating > 5;
   
-- Found invalid review ratings outside the allowed range (1-5).
-- Removed affected records because the true rating could not be determined.

---- FOR SELLERS
SELECT *
FROM sellers;

SELECT seller_id, COUNT(*) 
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Duplicate Check : customers table, order_items table, orders table......sellers table.
-- Checked for duplicate customer_id values, order_id values.....seller_id.
-- No duplicate found in all the tables.


----------- STANDARDIZATION OF DATA
---- FOR CUSTOMERS
SELECT *
FROM customers
ORDER BY customer_id;

SELECT *
FROM customers
WHERE city = 'Lagos';

SELECT *
FROM customers
WHERE city LIKE 'L%';

SELECT city, INITCAP(TRIM(city))
FROM customers;

SELECT account_status
FROM customers
GROUP BY account_status;

UPDATE customers
SET city = INITCAP(TRIM(city));

UPDATE customers
SET city = REPlACE (city, 'Port-Harcourt', 'Port Harcourt');

---- FOR PRODUCTS
SELECT *
FROM products
ORDER BY product_id;

SELECT DISTINCT category
FROM products;

UPDATE products
SET category = INITCAP(TRIM(category));

UPDATE products
 SET category = REPLACE (category, 'Beauty And Personal Care', 'Beauty and Personal Care');

---- FOR SELLERS
SELECT *
FROM sellers;

SELECT DISTINCT city
FROM sellers;

UPDATE sellers
SET city = INITCAP(TRIM(city));

UPDATE sellers
 SET city = REPLACE (city, 'Lago S', 'Lagos');

SELECT DISTINCT product_category
FROM sellers;

UPDATE sellers
SET product_category = INITCAP(TRIM(product_category));

UPDATE Sellers
SET product_category = 'Books and Stationery'
WHERE product_category IN ('Books','Books And Stationery', 'Books & Stationery');

SELECT 

------------ NULL OR BLANCK VALUES CHECK
---- FOR CUSTOMERS
SELECT *
FROM customers
WHERE customer_id IS NULL
	OR first_name IS NULL
	OR last_name IS NULL
	OR email IS NULL
	OR city IS NULL
	OR state IS NULL
	OR signup_date IS NULL;

SELECT COUNT(*)
FROM customers 
WHERE email IS NULL;

-- Data Quality Issue:
-- Found 16 customers records with NULL emails values
-- Email were not required for the current analysis.
-- Therefore the record is retained and flagged

---- FOR ORDER ITEMS
SELECT *
FROM order_items
WHERE item_id IS NULL
	OR order_id IS NULL
	OR product_id IS NULL
	OR quantity IS NULL
	OR unit_price IS NULL
	OR line_total IS NULL;
	
SELECT COUNT(*)
FROM order_items
WHERE unit_price IS NULL;

SELECT COUNT(*)
FROM order_items
WHERE line_total IS NULL;

SELECT *
FROM order_items 
WHERE unit_price IS NULL 
	OR line_total IS NULL;

SELECT p.product_id, oi.unit_price,p.unit_price AS uniit_price_product
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
WHERE oi.product_id = 'PROD0104';

SELECT COUNT(*)
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
WHERE oi.unit_price IS NULL 
	OR p.product_id IS NULL;
	
-- 97 records in order_items contained NULL values for unit_price and line_total. 
-- Investigation showed that corresponding product records were unavailable, 
-- preventing accurate imputation.
-- The records were flagged and excluded from revenue calculations.

---- FOR ORDERS
SELECT *
FROM orders
WHERE order_id IS NULL
	OR customer_id IS NULL
	OR seller_id IS NULL
	OR order_date IS NULL
	OR delivery_date IS NULL
	OR order_status IS NULL
	OR total_amount IS NULL;

SELECT COUNT(*)
FROM orders
WHERE delivery_date IS NULL;

-- Data Quality Issue:
--- Found 1510 orders records with NULL delivery date. 
-- Delivery date were not required for the current analysis.
-- Therefore the record is retained and flagged

---- FOR PAYMENTS
SELECT *
FROM payments
WHERE payment_id IS NULL
	OR order_id IS NULL
	OR payment_method IS NULL
	OR amount IS NULL
	OR payment_date IS NULL;

--checking if the payment has matching orders
SELECT COUNT(*)
FROM payments
WHERE amount IS NULL;

SELECT p.payment_id, p.order_id, p.amount, o.total_amount
FROM payments p 
JOIN orders o
	ON p.order_id = o.order_id
WHERE p.amount IS NULL;

UPDATE payments p
SET amount = o.total_amount
FROM orders o
WHERE p.order_id = o.order_id
	  AND p.amount IS NULL;

SELECT COUNT(*)
FROM payments
WHERE amount IS NULL;

-- Payments Table Missing Values
-- Initially identified 155 NULL values in payments.amount.
-- 50 records were successfully recovered using the corresponding orders.total_amount values.
-- 105 records remained NULL because the associated orders also contained NULL total_amount values.
-- These records were flagged for review and retained in the dataset.

---- FOR PRODUCTS
SELECT *
FROM products
WHERE product_id IS NULL
	OR product_name IS NULL
	OR category IS NULL
	OR unit_price IS NULL
	OR seller_id IS NULL;

-- Data Quality Issue:
-- Found 4 product records with NULL unit price values. 
-- Amount were not required for the current analysis.
-- Therefore the record is retained and flagged

---- FOR REVIEWS
SELECT *
FROM reviews
WHERE review_id IS NULL
	OR product_id IS NULL
	OR customer_id IS NULL
	OR order_id IS NULL
	OR rating IS NULL
	OR review_date IS NULL;

-- No NULL values were found in the reviews tables

---- FOR SELLERS
SELECT *
FROM sellers
WHERE seller_id IS NULL
	OR seller_name IS NULL
	OR onboarding_date IS NULL
	OR city IS NULL
	OR state IS NULL
	OR account_status IS NULL;

-- No NULL values were found in the sellers tables


---- ORDER TOTAL VALIDATION
-- To Check if the total amount matches the grand total
SELECT o.order_id, o.total_amount,
	   SUM(oi.line_total) Grand_Total,
	   ABS(o.total_amount - SUM(oi.line_total)) Difference
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) IS NOT NULL;

SELECT *
FROM order_items;

-- Total number of records that doesn't match the grand total
SELECT COUNT(*)
FROM(
SELECT o.order_id, o.total_amount,
	   SUM(oi.line_total) Grand_Total,
	   ABS(o.total_amount - SUM(oi.line_total)) Difference
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10
ORDER BY Difference DESC);

-- checking the total NULL values in the total_amount column
SELECT o.order_id, o.total_amount,
	   SUM(oi.line_total) Grand_Total,
	   ABS(o.total_amount - SUM(oi.line_total)) Difference
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING  o.total_amount IS NULL
ORDER BY Difference DESC;

-- Payments Table Missing Values
-- Found 150 records with NULL values in the amount column
-- Found 124 records that doesn't match the grand total column
-- The actual payment amounts could not be reliably determined from he available data 
-- so the records were flagged for review rather than automatically updated.


------ BUSINESS QUESTIONS
----1.CUSTOMER AQUISITION AND 30 DAY CONVERSION
-- For every customer who signup in 2024
-- Identify their signup state.
-- Check whether they made at least one purchase within 30 days of signing up.
-- Find the top 5 states by new customer signups.
-- Calculate the conversion percentage.

SELECT * 
FROM customers;

SELECT *
FROM orders;

-- New customers/customers who signup in 2024
SELECT customer_id, state, signup_date
FROM customers 
WHERE EXTRACT(YEAR FROM signup_date) = 2024 ;

-- converted customer within the last 30 days
WITH new_customers AS
(
	SELECT customer_id, state, signup_date
	FROM customers 
	WHERE EXTRACT(YEAR FROM signup_date) = 2024 
),
customer_conversion AS
(
	SELECT nc.customer_id, nc.state,
	CASE 
		WHEN MIN(o.order_date) <= nc.signup_date + INTERVAL '30 Days'
		THEN 1
		ELSE 0
	END AS converted_within_30days
	FROM new_customers nc
	LEFT JOIN orders o 
		ON nc.customer_id = o.customer_id
	GROUP BY nc.customer_id, nc.state, nc.signup_date
)
SELECT *
FROM customer_conversion;

-- new customers, converted customers and passentage rate conversion by state.
WITH new_customers AS
(
	SELECT customer_id, state, signup_date
	FROM customers 
	WHERE EXTRACT(YEAR FROM signup_date) = 2024 
),
customer_conversion AS
(
	SELECT nc.customer_id, nc.state,
	CASE 
		WHEN MIN(o.order_date) <= nc.signup_date + INTERVAL '30 Days'
		THEN 1
		ELSE 0
	END AS converted_within_30days
	FROM new_customers nc
	LEFT JOIN orders o 
		ON nc.customer_id = o.customer_id
	GROUP BY nc.customer_id, nc.state, nc.signup_date
)
SELECT state,
	   COUNT(*) AS new_customer_signup,
	   SUM(converted_within_30days) AS converted_customers,
	   ROUND(100.0 * SUM(converted_within_30days) / COUNT(*), 2) AS Percenatge_rate_conversion
FROM customer_conversion
GROUP BY state
ORDER BY converted_customers DESC;


---- 2.TOP 10 PRODUCT BY REVENUE 2024
SELECT *
FROM products;

SELECT p.product_name, p.category, SUM(line_total) AS total_revenue,
	   COUNT(DISTINCT oi.order_id) AS total_orders
FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
GROUP BY p.product_name, p.category
HAVING SUM(line_total) IS NOT NULL
ORDER BY total_revenue DESC
LIMIT 10;


---- 3.Seller Fulfilment Efficiency
-- Which sellers deliver orders the fastest while still keeping customers happy?
-- Total completed orders
-- Sellers with at least 20 completed orders

SELECT *
FROM sellers;

SELECT *
FROM orders;

SELECT *
FROM reviews;


SELECT s.seller_id, s.seller_name,
	   COUNT(DISTINCT(o.order_id)) AS total_orders
FROM sellers s
JOIN orders o
	ON s.seller_id = o.seller_id
WHERE order_status = 'Delivered' 
GROUP BY s.seller_id, s.seller_name, o.order_status
HAVING COUNT(DISTINCT(o.order_id)) >= 20
ORDER BY total_orders DESC
LIMIT 20;

--  Average customer rating and Average delivery time in days
SELECT s.seller_id, s.seller_name,
	   COUNT(DISTINCT(o.order_id)) AS total_orders,
	   ROUND(AVG(r.rating), 0) AS average_rating,
	   ROUND(AVG(o.delivery_date - o.order_date), 0) AS average_delivery_days
FROM sellers s
JOIN orders o
	ON s.seller_id = o.seller_id
JOIN reviews r
	ON o.order_id = r.order_id
WHERE order_status = 'Delivered' 
GROUP BY s.seller_id, s.seller_name, o.order_status
ORDER BY average_delivery_days 
LIMIT 20;


---- 4.QUARTERLY REVENUE TREND
SELECT *
FROM orders;

SELECT EXTRACT(YEAR FROM order_date) AS year,
	   EXTRACT(QUARTER FROM order_date) AS quarter,
	   ROUND(SUM(total_amount), 2) AS total_revenue,
	   COUNT(order_id) AS total_orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY EXTRACT(YEAR FROM order_date),
		 EXTRACT(QUARTER FROM order_date)
ORDER BY year, quarter;


----5. CUSTOMER SPEND SEGMENTATION
-- Business Question:
-- How can we segment customers based on their
-- total spending in 2024?

SELECT *
FROM customers;

SELECT MIN(total_amount), MAX(total_amount), AVG(total_amount)
FROM orders;

-- Calculate total spending for each customer.
WITH customer_spend AS 
(
	SELECT DISTINCT customer_id, SUM(total_amount) AS total_spend
	FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2024
	GROUP BY customer_id
),
-- Categorize customers based on spending.
	spend_segment AS 
(
	SELECT  *,
	CASE 
		WHEN total_spend > 500000 THEN 'High Spenders'
		WHEN total_spend BETWEEN 100000 AND 499999 THEN 'Medium Spenders'
		ELSE 'Low Spenders'
	END AS spend_group
	FROM customer_spend
)
SELECT spend_group, COUNT(customer_id) AS Total_customer,
	   ROUND(AVG(total_spend), 2) AS avg_spend_per_customer,
	   ROUND(SUM(total_spend), 2) AS total_revenue_contribution
FROM spend_segment
GROUP BY spend_group;


---- 6.PAYMENT METHOD PREFRENCE BY STATE
SELECT * 
FROM customers
WHERE account_status = 'Inactive';

SELECT *
FROM payments
WHERE order_id = 'ORD00192';

SELECT * 
FROM orders
WHERE customer_id = 'CUST0069';

SELECT DISTINCT payment_method
FROM payments;

SELECT *
FROM  payments p
JOIN orders o
	ON p.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id;

SELECT p.payment_method, c.state,
	   COUNT(*) AS total_transaction
FROM  payments p
JOIN orders o
	ON p.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY p.payment_method, c.state
ORDER BY total_transaction;

-- Identify the most popular payment method by state
WITH payment_stat AS
(
	SELECT c.state, p.payment_method, 
	COUNT(*) AS total_transaction,
	ROUND(SUM(p.amount), 2) AS total_amount,
	RANK() OVER(PARTITION BY c.state ORDER BY COUNT(*) DESC) AS rank_num
	FROM  payments p
	JOIN orders o
		ON p.order_id = o.order_id
	JOIN customers c
		ON o.customer_id = c.customer_id
	GROUP BY p.payment_method, c.state
)
SELECT *
FROM payment_stat
WHERE rank_num = 1
ORDER BY 1;


---- 7.REVIEW RATINGS AND SALES PERFORMANCE
SELECT *
FROM products;

SELECT *
FROM order_items;

SELECT *
FROM orders;

SELECT *
FROM reviews;

-- sales performance and product rating
SELECT p.product_id, p.product_name, oi.unit_price, 
	   SUM(oi.line_total) AS total_sales,
	   ROUND(AVG(rating), 2) AS average_rating
FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id
LEFT JOIN reviews r
	ON oi.product_id = r.product_id
WHERE oi.unit_price IS NOT NULL
GROUP BY p.product_id,p.product_name,oi.unit_price
ORDER BY total_sales DESC;


-- Rating category
SELECT *,
CASE 
	WHEN rating >= 4.0 THEN 'High Rated'
	WHEN rating >= 3.0 THEN 'Mid Rated'
	ELSE 'Low Rated'
END AS rating_category
FROM reviews;


WITH product_rating AS
(
	SELECT p.product_id, p.product_name, oi.unit_price, 
		   SUM(oi.line_total) AS total_revenue,
		   ROUND(AVG(rating), 2) AS average_rating
	FROM products p
	JOIN order_items oi
		ON p.product_id = oi.product_id
	LEFT JOIN reviews r
		ON oi.product_id = r.product_id
	WHERE oi.unit_price IS NOT NULL
	GROUP BY p.product_id,p.product_name,oi.unit_price
	ORDER BY total_revenue DESC
),
performance_rating AS 
(
	SELECT *,
	CASE 
		WHEN average_rating >= 4.0 THEN 'High Rated'
		WHEN average_rating >= 3.0 THEN 'Mid Rated'
		ELSE 'Low Rated'
	END AS rating_category
	FROM product_rating
)
SELECT rating_category,
	   COUNT(product_id) AS total_product,
	   ROUND(AVG(unit_price), 2) AS average_unit_price
 	   ROUND(SUM(total_revenue), 2) AS total_revenue,   
FROM performance_rating
GROUP BY rating_category
ORDER BY total_revenue DESC;


---- 8.TOP SELLER BONUS QUALIFICATION
-- find the top 10 sellers in 2024 who
-- completed at least 10 order
-- have an average rating of 10 and above 
-- Ranked bt total revenue
-- include, seller name, total orders, average rating, total revenue

SELECT *
FROM sellers;

SELECT *
FROM orders;

SELECT *
FROM reviews;


SELECT s.seller_id, s.seller_name, 
	   ROUND(SUM(o.total_amount), 2) AS total_revenue,
	   COUNT( DISTINCT o.order_id) AS total_orders
FROM sellers s
JOIN orders o
	ON  s.seller_id = o.seller_id
WHERE EXTRACT(YEAR FROM order_date) = 2024
	  AND o.total_amount IS NOT NULL
GROUP BY s.seller_id, s.seller_name
ORDER BY total_revenue DESC;

-- sellers that completed at least 10 orders
SELECT s.seller_id, s.seller_name, 
	   ROUND(SUM(o.total_amount), 2) AS total_revenue,
	   COUNT( DISTINCT o.order_id) AS total_orders
FROM sellers s
JOIN orders o
	ON  s.seller_id = o.seller_id
WHERE EXTRACT(YEAR FROM order_date) = 2024
	  AND o.total_amount IS NOT NULL
GROUP BY s.seller_id, s.seller_name, o.order_status
HAVING o.order_status = 'Delivered' 
AND COUNT( DISTINCT o.order_id) >= 10
ORDER BY total_revenue DESC;
















































	
