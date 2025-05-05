use zomato_db;
-- EDA
select * from customers;
select * from restaurants;
select * from orders;
select * from riders;
select * from deliveries;

INSERT INTO riders (rider_id, rider_name, sign_up) VALUES (0, 'No Rider', '2000-01-01');

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE deliveries;
TRUNCATE TABLE orders;
SET FOREIGN_KEY_CHECKS = 1;

DESCRIBE deliveries;

-- Check datasets
select count(*) from customers;
select count(*) from restaurants;
select count(*) from orders;
select count(*) from riders;
select count(*) from deliveries;

-- Identify null values 

select count(*) from customers
where customer_id IS NULL
OR customer_name IS NULL
OR reg_date IS NULL;

select count(*) from restaurants
where restaurant_id IS NULL
OR restaurant_name IS NULL
OR city IS NULL
OR opening_hours IS NULL;

select count(*) from orders
where order_id IS NULL
OR customer_id IS NULL
OR restaurant_id IS NULL
OR order_item IS NULL
OR order_date IS NULL
OR order_time IS NULL
OR order_status IS NULL
OR total_amount IS NULL;

select count(*) from riders
where rider_id IS NULL
OR rider_name IS NULL
OR sign_up IS NULL;

select count(*) from deliveries
where delivery_id IS NULL
OR order_id IS NULL
OR delivery_status IS NULL
OR delivery_time IS NULL
OR rider_id IS NULL;

-- ------------------
-- Analyis & Reports
-- ------------------

-- Q.1
-- Write a query to find the top 5 most frequently ordered dishis by customer called "Arjun Mehta" in the last one year.

WITH ordered_counts AS (
    SELECT 
        c.customer_id, 
        c.customer_name, 
        o.order_item AS dishes, 
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS ranks
    FROM orders o 
    JOIN customers c ON o.customer_id = c.customer_id 
    WHERE 
        c.customer_name = 'Arjun Mehta' AND
        o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY c.customer_id, c.customer_name, o.order_item
)
SELECT customer_name, dishes, total_orders 
FROM ordered_counts
WHERE ranks <= 5 
ORDER BY ranks;

-- Q.2
-- Write a query to find the orders in each month by customer called "Arjun Mehra"

SELECT c.customer_name, DATE_FORMAT(o.order_date, '%m') AS months , count(*) as total_orders
FROM orders o join customers c on o.customer_id = c.customer_id 
Where c.customer_name = 'Arjun Mehta' AND
o.order_date >= DATE_SUB('2024-03-31', INTERVAL 1 YEAR)
GROUP BY c.customer_id, c.customer_name, months 
ORDER BY months;

-- Q.3 Popular time stamps
-- Question : Identify the time slots during which the most orders are placed. based on 2-hours intervals.

--  Approch 1

SELECT 
	CASE 
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN "00:00 - 02:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN "02:00 - 04:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN "04:00 - 06:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN "06:00 - 08:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN "08:00 - 10:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN "10:00 - 12:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN "12:00 - 14:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN "14:00 - 16:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN "16:00 - 18:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN "18:00 - 20:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN "20:00 - 22:00"
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN "22:00 - 24:00"
	END as time_slot,	
	count(*) as total_order 
from orders
GROUP BY time_slot
ORDER BY total_order DESC;

-- Approch 2

SELECT CONCAT(LPAD(FLOOR(EXTRACT(HOUR FROM order_time)/2)*2, 2, '0') ,':00',' - ',LPAD(FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 ,2 , '0') ,':00') as time_slot,
COUNT(*) as total_orders FROM orders GROUP BY 1 ORDER BY 2 DESC;

-- Approch 3

SELECT FLOOR(EXTRACT(HOUR FROM order_time) / 2) as time_slot , count(*) total_count FROM orders GROUP BY 1 ORDER BY 2 DESC;

-- Q.4
-- Order Value Analysis
-- Question : Find the average order value per customer who has placed more than 190 orders.
-- Return customer_name , aov(average order value)

SELECT c.customer_name, count(o.order_id) AS total_order, round(AVG(o.total_amount),0) AS avg_amount
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name 
HAVING count(o.order_id) > 200 ORDER BY total_order DESC;

-- Q.5
-- Question : List the customers who have spent more than 55K in total on food orders.
-- return customer_name, customer_id

SELECT c.customer_name, count(o.order_id) AS total_order, round(sum(o.total_amount),0) AS total_spent
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name  HAVING total_spent > 50000 ORDER BY total_spent DESC;

-- Q.6 Orders without delivery
-- QUESTION : Write a query to find orders that were placed but not delivered.
-- Return each restaurant name, city, number of not delivered orders.

SELECT r.restaurant_name, r.city, count(*) not_deliver_orders 
FROM restaurants r RIGHT JOIN orders o on r.restaurant_id = o.restaurant_id  LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_status = 'Not Delivered' GROUP BY 1,2 ORDER BY 3 DESC;

-- Q.7 Restaurant revenue ranking
-- Question :  Rank restaurant by their total revenue from the last year, including there name, total revenue, and rank within there city.

WITH ranking_table AS
(
	SELECT r.city, r.restaurant_name, ROUND(SUM(o.total_amount),0) total_revenue,
	RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as ranks  
	FROM restaurants r RIGHT JOIN orders o on r.restaurant_id = o.restaurant_id 
    WHERE o.order_date >= DATE_SUB('2024-03-31', INTERVAL 1 YEAR) GROUP BY 1,2
)
SELECT * FROM ranking_table WHERE ranks = 1 ORDER BY total_revenue DESC;

-- Q.8 Most popular dish by city
-- Identify most popular dish in each city based on their number of orders.
 
WITH ranking_table AS
(
	SELECT r.city, o.order_item AS dish, count(o.order_id) AS orders, 
	RANK() OVER(PARTITION BY r.city ORDER BY count(o.order_id) DESC) as ranks
	FROM orders o JOIN restaurants r on o.restaurant_id = r.restaurant_id
	GROUP BY r.city, o.order_item
)
SELECT * FROM ranking_table WHERE ranks = 1;

-- Q.9 Customer churn 
-- Find the customer who havent placed an order in 2024 but did in 2023.

SELECT DISTINCT customer_id FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2023 AND customer_id IS NOT NULL 
	AND customer_id NOT IN ( SELECT DISTINCT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2024 AND customer_id IS NOT NULL );
    
-- Q.10 Financial Yearly Customer Churn
-- Identify customers active in Financial Year 2023-24 but inactive in Financial Year 2024-25.
 
 SELECT DISTINCT customer_id FROM orders
	WHERE order_date BETWEEN '2023-04-01' AND '2024-03-31'
		AND customer_id NOT IN (SELECT DISTINCT customer_id FROM orders WHERE order_date BETWEEN '2024-04-01' AND '2025-03-31');

-- Q.11 Cancellation Rate Comparision
-- Calculate and compare the order cancellation rate for each resaurant between the current year and the previous years and give churn trend.

WITH cancelation_2023 as (
	SELECT 
		r.restaurant_name, r.city, 
		o.restaurant_id,
		COUNT(d.delivery_id) as total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)/(COUNT(d.delivery_id)))*100,2) as churn_ratio
	from deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2022-04-01' AND '2023-03-31'
	GROUP BY o.restaurant_id
	HAVING COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)  > 0
	ORDER BY 2 DESC),    
cancelation_2024 as (
	SELECT 
		r.restaurant_name, r.city, 
		o.restaurant_id,
		COUNT(d.delivery_id) as total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)/(COUNT(d.delivery_id)))*100,2) as churn_ratio
	from deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2023-04-01' AND '2024-03-31'
	GROUP BY o.restaurant_id
	HAVING COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)  > 0
	ORDER BY 2 DESC),
cancelation_2025 as (
	SELECT 
		r.restaurant_name, r.city, 
		o.restaurant_id,
		COUNT(d.delivery_id) as total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)/(COUNT(d.delivery_id)))*100,2) as churn_ratio
	from deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2024-04-01' AND '2025-03-31'
	GROUP BY o.restaurant_id
	HAVING COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END)  > 0
	ORDER BY 2 DESC)

SELECT l.restaurant_name, l.city, l.churn_ratio as churn_2023, c.churn_ratio as churn_2024, r.churn_ratio as churn_2025,
	CASE 
		WHEN r.churn_ratio > c.churn_ratio AND c.churn_ratio > l.churn_ratio THEN 'Consistently Increased'
		WHEN c.churn_ratio > l.churn_ratio AND r.churn_ratio < c.churn_ratio THEN 'Decreased This Year'
		WHEN r.churn_ratio > c.churn_ratio AND c.churn_ratio < l.churn_ratio THEN 'Increased This  Year'
		WHEN r.churn_ratio < c.churn_ratio AND c.churn_ratio < l.churn_ratio THEN 'Consistently Decreased'
			ELSE 'Fluctuating or Stable'
	END AS churn_trend
FROM cancelation_2023 l 
JOIN cancelation_2024 c on l.restaurant_id = c.restaurant_id 
JOIN cancelation_2025 r on c.restaurant_id = r.restaurant_id;


-- Extra
Select YEAR(order_date) as year, COUNT(DISTINCT customer_id) AS unique_customers FROM orders GROUP BY 1;

SELECT 
  CASE WHEN MONTH(order_date) >= 4 THEN CONCAT(YEAR(order_date), '-', YEAR(order_date) + 1) ELSE CONCAT(YEAR(order_date) - 1, '-', YEAR(order_date)) END AS financial_year,
  COUNT(DISTINCT customer_id) AS unique_customers FROM orders GROUP BY financial_year;
  
SELECT order_status, count(order_status) from orders GROUP BY order_status;
SELECT delivery_status, count(delivery_status) from deliveries GROUP BY delivery_status;
  
-- Q.12 Rider Average Delivery Time
-- Determine each riders average delivery time.

SELECT 
    o.order_id,
    o.order_time,
    d.delivery_time,
    TIME_FORMAT(IF(d.delivery_time < o.order_time, TIMEDIFF(ADDTIME(d.delivery_time, '24:00:00'),o.order_time),TIMEDIFF(d.delivery_time,o.order_time)), '%H:%i:%s') AS time_diff,
    TIME_TO_SEC(IF(d.delivery_time < o.order_time, TIMEDIFF(ADDTIME(d.delivery_time, '24:00:00'),o.order_time),TIMEDIFF(d.delivery_time,o.order_time))) / 60 AS time_diff_minutes 
FROM orders o JOIN deliveries d ON o.order_id = d.order_id JOIN riders r ON d.rider_id = r.rider_id
Where d.delivery_status = 'Delivered';

SELECT r.rider_name, count(o.order_id) order_count,
ROUND(AVG(TIME_TO_SEC(IF(d.delivery_time < o.order_time, TIMEDIFF(ADDTIME(d.delivery_time, '24:00:00'),o.order_time),TIMEDIFF(d.delivery_time,o.order_time))) / 60),0) AS avergae_delivery_minutes
FROM riders r join deliveries d on d.rider_id = r.rider_id JOIN orders o on o.order_id = d.order_id 
WHERE o.order_status = 'Completed'
GROUP BY r.rider_id
ORDER BY 3;

-- Q.13 Monthly Restaurant Growth ratio
-- Calculate each restaurants growth ratio based on the total number of delivered orders since its joining.

WITH monthly_orders AS (
    SELECT 
        o.restaurant_id, 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
        COUNT(o.order_id) AS curr_month_order
    FROM orders o WHERE o.order_status = 'Completed' GROUP BY o.restaurant_id, month_year ORDER BY o.restaurant_id, month_year )
SELECT 
    restaurant_id,
    month_year,
    LAG(curr_month_order, 1) OVER ( PARTITION BY restaurant_id ORDER BY month_year ) AS prev_month_order,
    curr_month_order,
    ((curr_month_order - LAG(curr_month_order, 1) OVER ( PARTITION BY restaurant_id ORDER BY month_year ))/curr_month_order) *100 as growth_ratio
FROM monthly_orders 
ORDER BY month_year; 

-- Q.14 Customer Segmentation
-- Segement Customer into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). If a customers total spending exceeds the AOV,
-- label them as 'Gold' otherwise , label them as 'Silver'. Write an SQL query to determine each segment's total number of orders and total revenue.

SELECT 
	cx_category, SUM(orders) AS total_orders, SUM(total_spent) AS total_spent FROM
    (SELECT customer_id,
    DATE_FORMAT(order_date, '%Y-%m') AS month_year,
	ROUND(SUM(total_amount),0) total_spent,
	COUNT(order_id) orders,
	CASE WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'GOLD' ELSE 'Silver' END as cx_category
	FROM orders
	GROUP BY customer_id, month_year
	ORDER BY 2) 
AS t1 GROUP BY 1;

-- Q.15 Rider Monthly Earning
-- Calculate each riders total monthly earning, assuming they earn 8% of the order amount.

SELECT 
	d.rider_id, 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
    COUNT(o.order_id) orders, 
    ROUND(SUM(o.total_amount),0) total_revenue, 
    ROUND(SUM(o.total_amount) * 0.08, 0) AS riders_earning
FROM deliveries d JOIN orders o ON o.order_id = d.order_id
WHERE d.rider_id <> 0 -- AND 
-- o.order_status = 'Completed'
GROUP BY 1,2 
ORDER BY 1,2 ;

-- Q.16 Rider Rating Aanalysis
-- Find the number of 5-Star, 4-Star and 3-Star ratings for each riders.
-- riders recived this rating on the basis of delivery time.
-- If Order are deliverd in less then 15 minutes of order recived time the rider get 5 star rating 
-- If rider deliver in 15 - 20 minutes of order recived time the rider get 4 star rating 
-- If rider deliver more then 20 minutes of order recived time the rider get 3 star rating 

SELECT rider_id, rating, COUNT(*) as total_stars FROM 
	(
	SELECT t.rider_id, t.time_in_minutes,
	  CASE 
		WHEN t.time_in_minutes < 15 THEN '5 STAR'
		WHEN t.time_in_minutes BETWEEN 15 AND 20 THEN '4 STAR'
		ELSE '3 STAR' END AS rating FROM 
        (
		SELECT d.rider_id, ROUND( MOD( TIMESTAMPDIFF(SECOND, o.order_time, d.delivery_time) + 86400, 86400)  / 60,2) AS time_in_minutes
		FROM orders o JOIN deliveries d ON o.order_id = d.order_id WHERE d.delivery_status = 'Delivered'
        ) AS t 
	)AS s 
    GROUP BY 1, 2 
    ORDER BY 1, 3 DESC;
    
-- Q.17 Order frequency by Day
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.

SELECT * FROM 
	( SELECT 
		r.restaurant_name, 
		-- o.order_date, 
		DAYNAME(order_date) AS day_name, 
		COUNT(o.order_id) AS total_order,
		RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as ranking
	FROM orders o JOIN restaurants r on o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
    ) as t1 where ranking = 1;

-- Q.18 Customer Lifetime Value (CLV)
-- Calculate the total revenue generated by each costomer over all their orders.

SELECT 
	o.customer_id,
	c.customer_name,
    COUNT(o.order_id) total_order,
    ROUND(SUM(o.total_amount),0) total_revenue
FROM orders o JOIN customers c on c.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY 1;

-- Q.19 Monthly Sales Trend
-- Identify sales trend by comparing each months total sales to previous month.

SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS year_months,
ROUND(LAG(SUM(total_amount),1) OVER(ORDER BY DATE_FORMAT(order_date, '%Y-%m')),0) as prev_month_sale,
ROUND(SUM(total_amount),0) as current_total_sale,
CASE WHEN SUM(total_amount) > LAG(SUM(total_amount),1) OVER(ORDER BY DATE_FORMAT(order_date, '%Y-%m')) THEN '▲ Up Trend' ELSE '▼ Down Trend' END AS trend_status
FROM orders
WHERE order_status = 'Completed'
GROUP BY 1;

-- Q.20 Rider Efficiency
-- Evaluate riders efficiency by determining average delivery time and identifying those with the lowest and highest averages.

SELECT 
	MIN(time_in_minutes) as min_avg_delivery_time,
	MAX(time_in_minutes) as max_avg_delivery_time FROM 
    (
	SELECT 
		d.rider_id,
		ROUND(AVG(MOD( TIMESTAMPDIFF(SECOND, o.order_time, d.delivery_time) + 86400, 86400)  / 60),0) AS time_in_minutes
	FROM orders o JOIN deliveries d on o.order_id = d.order_id WHERE d.delivery_status = 'Delivered' AND d.rider_id <> 0
	GROUP BY 1
    ) as t1;

-- Q.21 Order Item Popularity 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.
SELECT order_item, season, total_orders FROM(
	SELECT 
	  order_item, 
	  season, 
	  COUNT(order_id) AS total_orders,
	  RANK() OVER(PARTITION BY season ORDER BY COUNT(order_id) DESC) AS item_rank
	FROM (
		SELECT 
		  order_item,
		  order_id,
		  CASE
			WHEN MONTH(order_date) BETWEEN 3 AND 6 THEN 'Summer'
			WHEN MONTH(order_date) BETWEEN 7 AND 10 THEN 'Monsoon'
			ELSE 'Winter'
		  END AS season
		FROM orders
		WHERE order_status = 'Completed'
	) AS t1
	GROUP BY order_item, season
	ORDER BY season, total_orders DESC) AS t2 
    WHERE item_rank <= 3;

    
-- Q.22 
-- Rank each city based on the total revenue for last year 2023

SELECT r.city, ROUND(SUM(o.total_amount),0) total_revenue, RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS ranking
FROM orders o JOIN restaurants r on o.restaurant_id = r.restaurant_id
WHERE YEAR(o.order_date) = 2023 GROUP BY 1;

-- Q.23 Quarterly Active Customers
-- Count unique active customers each quarter.

SELECT 
    CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) AS quarter,
    COUNT(DISTINCT customer_id) AS customer_count,
    GROUP_CONCAT(DISTINCT customer_id ORDER BY customer_id SEPARATOR ', ') AS customer_ids
FROM orders
WHERE order_status = 'Completed'
GROUP BY quarter
ORDER BY quarter;

-- Q24 Quarterly Customer Churn
-- Identify customers who became inactive in the following quarter.

-- Customers who did not return in the next quarter or returned after a long gap
WITH customer_quarters AS (
    SELECT 
        customer_id,
        CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) AS quarter
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, quarter
),
quarter_pairs AS (
    SELECT 
        q1.quarter AS current_quarter,
        q2.quarter AS next_quarter,
        q1.customer_id
    FROM customer_quarters q1
    LEFT JOIN customer_quarters q2 
        ON q1.customer_id = q2.customer_id 
       AND q2.quarter = (
           SELECT MIN(quarter) 
           FROM customer_quarters 
           WHERE quarter > q1.quarter
       )
)
SELECT 
    current_quarter AS quarter,
    COUNT(DISTINCT customer_id) AS churned_count,
    GROUP_CONCAT(DISTINCT customer_id ORDER BY customer_id SEPARATOR ', ') AS churned_customer_ids
FROM quarter_pairs
WHERE next_quarter IS NULL 
   OR DATEDIFF(
        STR_TO_DATE(CONCAT(next_quarter, '-01'), '%Y-Q%q-%d'),
        STR_TO_DATE(CONCAT(current_quarter, '-01'), '%Y-Q%q-%d')
   ) > 90  -- More than one quarter gap
GROUP BY current_quarter
ORDER BY current_quarter;

-- Q25 Yearly Customer Churn
-- Find customers who stopped ordering for over a year or never returned.

WITH customer_years AS (
    SELECT 
        customer_id,
        YEAR(order_date) AS year
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, YEAR(order_date)
),

customer_year_pairs AS (
    SELECT 
        cy1.customer_id,
        cy1.year AS last_active_year,
        MIN(cy2.year) AS next_active_year
    FROM customer_years cy1
    LEFT JOIN customer_years cy2 
        ON cy1.customer_id = cy2.customer_id 
        AND cy2.year > cy1.year
    GROUP BY cy1.customer_id, cy1.year
)

SELECT 
    last_active_year + 1 AS churn_year,
    COUNT(DISTINCT customer_id) AS churned_customers_count,
    GROUP_CONCAT(DISTINCT customer_id ORDER BY customer_id SEPARATOR ', ') AS churned_customer_ids
FROM customer_year_pairs
WHERE next_active_year IS NULL 
   OR next_active_year > last_active_year + 1
GROUP BY last_active_year
ORDER BY churn_year;

-- END OF REPORTS --