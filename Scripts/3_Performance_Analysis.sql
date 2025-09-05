--Performance Analysis--

--
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
--

WITH yearly_product_sales AS (
  SELECT
    YEAR(f.order_date) AS order_year,
    p.product_name,
    SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
     ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
   YEAR(f.order_date),
   P.product_name
)
SELECT
   order_year,
   product_name,
   current_sales,
   AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
   current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
   CASE 
      WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
      WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
      ELSE 'Avg'	  
   END avg_change,

  --year over year analysis--
  LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
  current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
  CASE 
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
     ELSE 'No change'	  
   END py_change
  FROM yearly_product_sales
  ORDER BY product_name, order_year;