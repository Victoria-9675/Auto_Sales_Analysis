-- CREATE DATABASE --
CREATE DATABASE AutoSales_Warehouse;
USE AutoSales_Warehouse;

-- 1. Create Product Dimension Table
CREATE TABLE dim_products (
    product_code VARCHAR(50) PRIMARY KEY,
    product_line VARCHAR(50),
    msrp DECIMAL(10, 2)
);

-- 2. Create Customer Dimension Table
CREATE TABLE dim_customers (
    customer_name VARCHAR(150) PRIMARY KEY,
    phone VARCHAR(50),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(50),
    country VARCHAR(100)
);

-- 3. Create Sales Fact Table
CREATE TABLE fact_sales (
    order_number INT,
    product_code VARCHAR(50),
    customer_name VARCHAR(150),
    order_date TEXT, -- Keeping as TEXT temporarily for easy import, we can convert later
    status VARCHAR(50),
    deal_size VARCHAR(50),
    quantity_ordered INT,
    price_each DECIMAL(10, 2),
    sales DECIMAL(10, 2),
    PRIMARY KEY (order_number, product_code),
    FOREIGN KEY (product_code) REFERENCES dim_products(product_code),
    FOREIGN KEY (customer_name) REFERENCES dim_customers(customer_name)
);

SELECT * FROM fact_sales;

-- Turn off safe updates temporarily to allow the conversion
SET SQL_SAFE_UPDATES = 0;

-- Convert the text dates into actual date formats
UPDATE fact_sales 
SET order_date = STR_TO_DATE(order_date, '%d/%m/%Y');

-- Change the column type from text to actual DATE
ALTER TABLE fact_sales 
MODIFY COLUMN order_date DATE;

-- Turn safe updates back on
SET SQL_SAFE_UPDATES = 1;

CREATE OR REPLACE VIEW view_regional_product_ranking AS
WITH ranked_sales AS (
    SELECT 
        c.country,
        p.product_line,
        SUM(f.sales) AS total_revenue,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(f.sales) DESC) as sales_rank
    FROM fact_sales f
    JOIN dim_customers c ON f.customer_name = c.customer_name
    JOIN dim_products p ON f.product_code = p.product_code
    GROUP BY c.country, p.product_line
)
SELECT country, product_line, total_revenue
FROM ranked_sales
WHERE sales_rank <= 3;

SELECT * FROM view_regional_product_ranking;