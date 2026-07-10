-- EDA--
-- Data Overview --
-- 1.Total Sales
SELECT SUM(sales) FROM fact_sales;

-- 2. Total Customers
SELECT COUNT(DISTINCT customer_name) FROM dim_customers;

-- 3. Total Products
SELECT COUNT(DISTINCT product_code) AS total_products
FROM dim_products;

-- 4. Total Countries
SELECT COUNT(DISTINCT country) FROM dim_customers;

-- 5. Total Cities
SELECT COUNT(DISTINCT city) FROM dim_customers;

-- 6. Total Quantity ordered
SELECT SUM(quantity_ordered) FROM fact_sales;

-- 7.Avg Sales
SELECT ROUND(AVG(sales),2) FROM fact_sales;

-- 8.Avg Quantity
SELECT ROUND(AVG(quantity_ordered),2) FROM fact_sales;

-- 9. Highest Sales
SELECT p.product_code,
       p.product_line,
       SUM(f.sales) AS total_sales_revenue,
       SUM(f.quantity_ordered) AS total_units_sold
FROM fact_sales f
JOIN dim_products p 
ON f.product_code = p.product_code
GROUP BY p.product_code, p.product_line
ORDER BY total_sales_revenue DESC
LIMIT 5;

-- 10.Avg Selling Price
SELECT ROUND(AVG(price_each),2) FROM fact_sales;

-- Time Analysis
-- 11. Revenue by month
SELECT
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(sales), 2) AS total_revenue
FROM fact_sales
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_revenue DESC;

-- 12. Revenue by Year
SELECT YEAR(order_date) AS Year,
ROUND(SUM(sales),2) AS total_revenue
FROM fact_sales
GROUP BY Year
ORDER BY total_revenue DESC;

-- 13. Monthly Sales Trend 
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(sales), 2) AS monthly_sales
FROM fact_sales
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- 13. Running Total( Shows How revenue acummulated over time)
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month_number,
        MONTHNAME(order_date) AS month_name,
        SUM(sales) AS monthly_revenue
    FROM fact_sales
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)
SELECT
    year,
    month_number,
    month_name,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(monthly_revenue) OVER (
            ORDER BY year, month_number
        ),
        2
    ) AS running_total
FROM monthly_sales
ORDER BY
    year,
    month_number;
    
-- Product Analysis
-- 14.Revenue by Product Line
SELECT  p.product_line, SUM(f.sales) AS total_revenue FROM fact_sales f
JOIN dim_products p
ON f.product_code = p.product_code
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 15. Quantity By Product Line
SELECT p.product_line, SUM(f.quantity_ordered) As Total_quantity FROM fact_sales f
JOIN dim_products p
ON p.product_code = f.product_code
GROUP BY p.product_line
ORDER BY Total_quantity DESC;

-- 16. Products sold below MSRP
SELECT p.product_code,
       p.product_line,
       p.msrp,
       f.price_each As actual_selling_price,
       ROUND((p.msrp - f.price_each), 2) AS discount_amount
FROM fact_sales f
JOIN dim_products p
ON f.product_code = p.product_code
WHERE f.price_each < p.msrp
ORDER BY discount_amount DESC;

-- 16. Avg selling price of msrp
SELECT
       p.product_line,
       AVG(p.msrp) AS avg_msrp,
       AVG(f.price_each) As avg_selling_price,
       ROUND(AVG(p.msrp - f.price_each),2) AS avg_discount_amount
FROM fact_sales f
JOIN dim_products p
ON f.product_code = p.product_code
WHERE f.price_each < p.msrp
GROUP BY p.product_line
ORDER BY avg_discount_amount DESC;

-- Customer Analysis
-- 17. Top Customers
SELECT
    c.customer_name,
    ROUND(SUM(f.sales),2) AS total_revenue
FROM fact_sales f
JOIN dim_customers c
ON f.customer_name = c.customer_name
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 18. Orders per Customers
SELECT  c.customer_name,
        COUNT(DISTINCT f.order_number) AS Total_orders
FROM dim_customers c
JOIN fact_sales f 
ON f.customer_name = c.customer_name
GROUP BY c.customer_name
ORDER BY Total_orders DESC;

-- 19. Revenue by Country
SELECT c.country, SUM(f.sales) AS Total_Revenue FROM dim_customers c
JOIN fact_sales f
ON c.customer_name = f.customer_name
GROUP BY c.country
ORDER BY Total_Revenue DESC;

-- 20. Revenue by City
SELECT c.city, SUM(f.sales) AS Total_Revenue FROM dim_customers c
JOIN fact_sales f
ON c.customer_name = f.customer_name
GROUP BY c.city
ORDER BY Total_Revenue DESC; 

-- 21. Avg per_order_spendings
SELECT c.customer_name,
       COUNT(DISTINCT f.order_number) AS total_orders,
       ROUND(SUM(f.sales), 2) AS total_spent,
       ROUND(AVG(f.sales), 2) AS avg_per_order_spending
FROM fact_sales f
JOIN dim_customers c 
  ON f.customer_name = c.customer_name 
GROUP BY c.customer_name
ORDER BY avg_per_order_spending DESC;

-- Geographic Analysis
-- 22.Revenue By Country
SELECT c.country, SUM(f.sales) AS Total_sales FROM dim_customers c
JOIN fact_sales f
ON c.customer_name = f.customer_name
GROUP BY c.country
ORDER BY Total_sales DESC;

-- 23. Revenue by City
SELECT c.city, SUM(f.sales) AS Total_sales FROM dim_customers c
JOIN fact_sales f
ON c.customer_name = f.customer_name
GROUP BY c.city
ORDER BY Total_sales DESC;

-- 24.Number of customers per country
SELECT
    country,
    COUNT(DISTINCT customer_name) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Deal size analysis
-- 25. Revenue by Deal Size
SELECT deal_size,
       ROUND(SUM(sales),2) AS total_revenue
FROM fact_sales
GROUP BY deal_size
ORDER BY total_revenue DESC;
        
-- 26. Orders by Deal Size
SELECT deal_size,
       COUNT(DISTINCT order_number) AS total_orders
FROM fact_sales
GROUP BY deal_size
ORDER BY total_orders DESC;

-- 27.Order Status Analysis
SELECT status,
       COUNT(*) AS total_orders,
	   ROUND(SUM(sales),2) AS revenue
FROM fact_sales
GROUP BY status
ORDER BY revenue DESC;

-- Ranking
-- 28. Rank customers by revenue
SELECT c.customer_name,
       ROUND(SUM(f.sales), 2) AS total_revenue_generated,
       RANK() OVER (ORDER BY SUM(f.sales) DESC) AS customer_rank
FROM fact_sales f
JOIN dim_customers c 
  ON f.customer_name = c.customer_name
GROUP BY c.customer_name;

-- Business insights
-- 1. Classic Cars generated the highest revenue.
-- 2. USA generated highest total sales making it the company strongest performing market.
-- 3. Medium deal sizes accounted for the highest number of orders.
-- 4. The top five customers generated a significant portion of total revenue.
-- 5. Sales peaked during November, indicating seasonal demand.
-- 6.Madrid is the city with the highest revenue in terms of city.
-- 7. 2019 had the highest revenue.

----------------- END!!!---------