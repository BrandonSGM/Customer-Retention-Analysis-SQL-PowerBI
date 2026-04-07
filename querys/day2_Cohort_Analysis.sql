/*
=======================
DAY 2. Cohort Analysis
=======================
*/

-- Step 2.1: First Purchase

SELECT customer_id, 
	DATE_TRUNC('month', MIN(order_date)) AS cohort_month
	FROM fact_customer_orders
GROUP BY 1
ORDER BY 2;

-- Step 2.2: Cohort Customers

WITH first_purchase AS (
	SELECT customer_id, 
		DATE_TRUNC('month', MIN(order_date)) AS cohort_month
		FROM fact_customer_orders
	GROUP BY 1
	ORDER BY 2
)
SELECT 
	f.cohort_month,
	DATE_TRUNC('month', o.order_date) AS order_month,
	COUNT(DISTINCT o.customer_id) AS active_customers
FROM fact_customer_orders o
JOIN first_purchase f
ON o.customer_id = f.customer_id
GROUP BY 1,2
ORDER BY 1,2;
/*Las cohortes adquiridas en los primeros meses de 2024 concentran el mayor volumen de clientes
y mantienen recurrencia estable durante múltiples periodos, especialmente enero, febrero y marzo.

Esto evidencia una base histórica de clientes con comportamiento sostenido a largo plazo.

Las cohortes recientes presentan menor volumen de recurrencia absoluta; sin embargo, este comportamiento
debe interpretarse considerando que su ventana temporal de observación es más corta.

En términos generales, el negocio muestra una fuerte capacidad de retención en cohortes maduras,
mientras que las cohortes nuevas requieren análisis adicional para confirmar su consolidación.

La recurrencia no sigue una caída lineal; se observan reactivaciones periódicas en cohortes maduras,
lo que sugiere un comportamiento de compra intermitente más que abandono definitivo.

Se observa una disminución progresiva en el volumen de nuevas cohortes después del primer semestre de 2024,
lo que puede indicar menor capacidad de adquisición comercial en periodos posteriores.
*/

-- Step 2.3: Cohort Retention Percentage

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
	DATE_TRUNC('month', o.order_date) AS order_month
FROM fact_customer_orders AS o
JOIN first_purchase AS f
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
	order_month,
	COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
GROUP BY 1,2
)

SELECT
	r.cohort_month,
	r.order_month,
	r.active_customers,
	c.cohort_customers,
	ROUND(
		r.active_customers * 100.0 / c.cohort_customers,
		2
	) AS retention_rate
FROM retention_data AS r
JOIN cohort_size AS c
ON r.cohort_month = c.cohort_month
ORDER BY 1,2;

/*
Se observa que las cohortes históricas mantienen niveles de recompra sostenidos a lo largo
del tiempo, con reactivaciones periódicas que indican comportamiento intermitente más que abandono definitivo.

La retención no sigue una caída lineal, sino que presenta fluctuaciones mensuales compatibles
con variaciones estacionales moderadas.

Las cohortes de mayor tamaño, especialmente las adquiridas en el primer semestre de 2024,
conservan porcentajes de retención estables entre 30% y 40% durante múltiples periodos,
lo que evidencia una base comercial sólida.

En cohortes recientes aparecen porcentajes elevados de retención, aunque estos resultados deben
analizarse con cautela debido al bajo tamaño muestral de dichas cohortes.
*/

-- Step 2.4: Month Index
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
	DATE_TRUNC('month', o.order_date) AS order_month,
	(
		EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), f.cohort_month)) *12 
		+
		EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), f.cohort_month))
	) AS month_index
FROM fact_customer_orders AS o
JOIN first_purchase AS f
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
)

SELECT 
	r.cohort_month,
	r.month_index,
	r.active_customers,
	c.cohort_customers,
	ROUND(
		r.active_customers * 100.0 / c.cohort_customers,
		2
	) AS retention_rate
FROM retention_data r
JOIN cohort_size c
ON r.cohort_month = c.cohort_month
ORDER BY 1,2;

/*
Las cohortes maduras presentan patrones de recompra sostenidos con reactivaciones periódicas,
lo que evidencia fidelidad parcial y permanencia comercial a largo plazo.

La mayor parte de la retención converge en un rango estructural entre 30% y 40%, indicando una base
estable de clientes recurrentes.

La volatilidad aumenta en cohortes recientes debido al menor tamaño de muestra, lo que incrementa
la sensibilidad porcentual ante pequeñas variaciones de clientes activos.

En algunos month_index avanzados se observan caídas temporales hacia niveles cercanos al 10%-18%,
compatibles con pérdida parcial de recurrencia en ciclos largos de recompra.
 
*/

