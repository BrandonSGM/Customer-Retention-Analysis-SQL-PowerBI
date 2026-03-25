/*
=======================
DAY 1. EDA
=======================
*/
-- Step 1.1: Total customers 
SELECT 
	COUNT(DISTINCT(customer_id)) AS total_different_customers
FROM fact_customer_orders; --500

-- Step 1.2: Total re-customers
SELECT 
	customer_id,
	COUNT(order_id) AS quantity_of_orders
FROM fact_customer_orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY 2 DESC;

-- Step 1.3: Identifying the first and last order of each customer.
SELECT
	customer_id,
	COUNT(*) AS quantity_of_orders,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order
FROM fact_customer_orders
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 2 DESC;

-- Step 1.4: Customer Active Span
SELECT
	customer_id,
	COUNT(*) AS quantity_of_orders,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	MAX(order_date) - MIN(order_date) AS active_days
FROM fact_customer_orders
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 5 ASC; -- 728 a 99 días

                
-- Step 1.5: Initial Classification of customers
WITH classification AS (SELECT
	customer_id,
	COUNT(*) AS quantity_of_orders,
	CASE
		WHEN COUNT(*) = 1 THEN 'One-Time'
		WHEN COUNT(*) BETWEEN 2 AND 4 THEN 'Repeat'
		ELSE 'Frecuent'
	END AS customer_type
FROM fact_customer_orders 
GROUP BY 1
ORDER BY 2 DESC
),
segments AS(
SELECT
	customer_type,
	COUNT(*) AS quantity_of_customers,
	SUM(COUNT(*)) OVER() AS total_orders
FROM classification
GROUP BY 1
ORDER BY 2 DESC
)
SELECT
	customer_type, 
	quantity_of_customers,
	ROUND(quantity_of_customers * 100.0 / total_orders,2) AS pct
FROM segments
ORDER BY 3 DESC;
/*
"customer_type"	"pct"
"Frecuent"	95.60
"Repeat"	4.20
"One-Time"	0.20
*/
/*
Se evidencia que la empresa tiene un grupo de clientes consolidados comercialmente y con alta frecuencia de compra
*/
-- Step 1.6: Calculation of retention rate
WITH customer_orders AS (
SELECT
	customer_id,
	COUNT(*) AS total_orders
FROM fact_customer_orders
GROUP BY 1
)
SELECT
	ROUND(
		SUM(
			CASE WHEN total_orders > 1 THEN 1 ELSE 0 END
		) *100.0 / COUNT(*)
	,2) AS retention_rate
FROM customer_orders; --99.80%
