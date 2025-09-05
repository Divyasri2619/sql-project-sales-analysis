-- Cumulative Analysis --

--
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.
--

SELECT
   order_date,
   total_sales,
   SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
   AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM
(

 SELECT 
    DATETRUNC(YEAR, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
 FROM gold.fact_sales
 WHERE order_date is NOT NULL
 GROUP BY DATETRUNC(YEAR, order_date)
) t

