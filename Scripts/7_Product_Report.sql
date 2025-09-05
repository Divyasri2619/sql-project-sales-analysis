-- Product Report --

--
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
--

WITH base_query AS(
-- 1.Base Query: Retrieves core columns from fact_sales and dim_products --
SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date is NOT NULL
),

 product_aggregation AS(
-- 2.Product Aggregations: Summarizes key metrics at the product level --
SELECT 
   product_key,
   product_name,
   category,
   subcategory,
   cost,
   COUNT(DISTINCT order_number) AS total_orders,
   SUM(sales_amount) AS total_sales,
   COUNT(quantity) AS total_quantity,
   COUNT(DISTINCT customer_key) AS total_customers,
   MAX(order_date) AS last_sale_date,
   DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
   ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query

GROUP BY
   product_key,
   product_name,
   category,
   subcategory,
   cost
)

SELECT
   product_key,
   product_name,
   category,
   subcategory,
   last_sale_date,
   cost,
   DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
   CASE 
      WHEN total_sales > 50000 THEN 'High performer'
      WHEN total_sales >= 10000 THEN 'Mid performer'
      ELSE 'Low performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- compute average order value --
CASE
    WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
END AS avg_order_revenue,
--  compute average monthly revenue --
CASE
    WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_revenue

FROM product_aggregation







