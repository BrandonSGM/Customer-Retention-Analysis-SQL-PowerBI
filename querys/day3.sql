/*
========================
Day 3: Create views
========================
*/

-- Step 3.1: Heat map retention cohort
CREATE VIEW vw_customer_retention_cohort AS(
WITH first_purchase AS (
SELECT
	customer_id,
	DATE_TRUNC('month', MIN(order_date)) AS cohort_month
FROM fact_customer_orders
GROUP BY 1
),

cohort_activity AS (
SELECT
	f.customer_id,
	f.cohort_month,
	(
		EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), f.cohort_month))*12
		+
		EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), f.cohort_month))
	) AS month_index
FROM fact_customer_orders o
JOIN first_purchase f
ON o.customer_id = f.customer_id
),

cohort_size AS (
SELECT
	cohort_month,
	COUNT(DISTINCT customer_id) AS cohort_customers
FROM first_purchase
GROUP BY 1
),

retention_data AS (
SELECT
	cohort_month,
	month_index,
	COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
GROUP BY 1,2
),

final_retention AS (
SELECT
	r.cohort_month,
	r.month_index,
	ROUND(
		r.active_customers::numeric / c.cohort_customers,
	3
	) AS retention_rate
FROM retention_data r
JOIN cohort_size c
ON r.cohort_month = c.cohort_month
)

SELECT
	cohort_month,

	MAX(CASE WHEN month_index = 0 THEN retention_rate END) AS M0,
	MAX(CASE WHEN month_index = 1 THEN retention_rate END) AS M1,
	MAX(CASE WHEN month_index = 2 THEN retention_rate END) AS M2,
	MAX(CASE WHEN month_index = 3 THEN retention_rate END) AS M3,
	MAX(CASE WHEN month_index = 4 THEN retention_rate END) AS M4,
	MAX(CASE WHEN month_index = 5 THEN retention_rate END) AS M5,
	MAX(CASE WHEN month_index = 6 THEN retention_rate END) AS M6,
	MAX(CASE WHEN month_index = 7 THEN retention_rate END) AS M7,
	MAX(CASE WHEN month_index = 8 THEN retention_rate END) AS M8,
	MAX(CASE WHEN month_index = 9 THEN retention_rate END) AS M9,
	MAX(CASE WHEN month_index = 10 THEN retention_rate END) AS M10,
	MAX(CASE WHEN month_index = 11 THEN retention_rate END) AS M11

FROM final_retention
GROUP BY 1
ORDER BY 1
);

-- Step 3.2: Customers classification 

CREATE VIEW vw_customer_classification AS(
WITH classification AS (
SELECT
	customer_id,
	COUNT(*) AS quantity_of_orders,
	CASE
		WHEN COUNT(*) = 1 THEN 'One-Time'
		WHEN COUNT(*) BETWEEN 2 AND 4 THEN 'Repeat'
		ELSE 'Frequent'
	END AS customer_type
FROM fact_customer_orders
GROUP BY customer_id
)
SELECT *
FROM classification
);

-- Step 3.3: Customers behavior summary
CREATE VIEW vw_customer_behavior_summary AS (
WITH customer_summary AS(
SELECT 
	customer_id, 
	COUNT(*) AS total_orders,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	MAX(order_date) - MIN(order_date) AS active_days,
	ROUND(SUM(quantity * unit_price * (1-discount)),2) AS revenue
FROM fact_customer_orders
GROUP BY 1
) 
SELECT 
	COUNT(*) AS total_customers,
	SUM(total_orders) AS total_orders,
	ROUND(AVG(total_orders),2) AS avg_orders_per_customer,
	ROUND(
		SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)::numeric/ COUNT(*)
	,3) AS retention_rate,
	ROUND(AVG(active_days),2) AS avg_active_days,
	ROUND(AVG(revenue),2) AS avg_ticket,
	SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customer,
	SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customer
FROM customer_summary
);
SELECT * FROM vw_customer_behavior_summary;

