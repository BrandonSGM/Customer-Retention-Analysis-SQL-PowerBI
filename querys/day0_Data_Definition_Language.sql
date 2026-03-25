-- Database: Customer Retention Analysis

-- DROP DATABASE IF EXISTS "Customer Retention Analysis";

CREATE DATABASE "Customer Retention Analysis"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Definition of dim_customers table
CREATE TABLE dim_customers (
	customer_id INT PRIMARY KEY, 
	signup_date DATE,
	segment VARCHAR(50),
	loyalty_level VARCHAR(50),
	city VARCHAR(50) 
);
-- Definition of dim_products table
CREATE TABLE dim_products (
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50),
	category VARCHAR(50)
);

-- Definition of fact_customer_orders table
CREATE TABLE fact_customer_orders (
	order_id INT PRIMARY KEY,
	customer_id INT,
	product_id INT,
	order_date DATE ,
	channel VARCHAR(50),
	region VARCHAR(50),
	quantity INT, 
	unit_price NUMERIC,
	discount NUMERIC,
	FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
	FOREIGN KEY (product_id) REFERENCES dim_products(product_id)
);

-- Quality data

-- Validation of different types of channel 
SELECT DISTINCT channel 
FROM fact_customer_orders;

-- Validation of different regions
SELECT DISTINCT region 
FROM fact_customer_orders;


-- Validation of null values order date
SELECT * FROM fact_customer_orders
WHERE order_date IS NULL;

-- Validation of referential intregrity of customer_id
SELECT f.customer_id 
FROM fact_customer_orders f
LEFT JOIN dim_customers c
ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Validation of referential integrity of product_id
SELECT f.product_id 
FROM fact_customer_orders f
LEFT JOIN dim_products p
ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

