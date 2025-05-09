# Analysis & Reports
----

<p align="center">
  <img src="https://github.com/nileshsharma-dp/zomato_db_analytics/blob/main/Images/zomato_main_2.png" width="100%" alt="Zomato Main">
</p>

----
## Q1. Top 5 Most Frequently Ordered Dishes by “Arjun Mehta” in the Last Year

**Description:**  
List the top 5 dishes that customer **Arjun Mehta** ordered most often in the 12 months leading up to today.

```sql
WITH dish_order_counts AS (
  SELECT
    c.customer_id,
    c.customer_name,
    o.order_item AS dish,
    COUNT(*) AS total_orders,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dish_rank
  FROM orders o
  JOIN customers c
    ON o.customer_id = c.customer_id
  WHERE
    c.customer_name = 'Arjun Mehta'
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  GROUP BY
    c.customer_id,
    c.customer_name,
    o.order_item
)

SELECT
  customer_name,
  dish,
  total_orders
FROM dish_order_counts
WHERE dish_rank <= 5
ORDER BY dish_rank;

```

## Q2. Monthly Order Counts for “Arjun Mehta”

**Description:**  
Show the number of orders placed by Arjun Mehta in each month over the last year.

```sql
SELECT
  c.customer_name,
  DATE_FORMAT(o.order_date, '%Y-%m') AS month_period,
  COUNT(*)                          AS total_orders
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
WHERE
  c.customer_name = 'Arjun Mehta'
  AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY
  c.customer_id,
  c.customer_name,
  month_period
ORDER BY
  month_period;
  ```

## Q3. Popular Order Time Slots (2‑Hour Intervals)

**Description:**  
Identify the 2‑hour time windows during which the most orders are placed.

Approach 1: Hard‑coded CASE

```sql
SELECT
  CASE
    WHEN HOUR(order_time) BETWEEN 0  AND 1  THEN '00:00 - 02:00'
    WHEN HOUR(order_time) BETWEEN 2  AND 3  THEN '02:00 - 04:00'
    WHEN HOUR(order_time) BETWEEN 4  AND 5  THEN '04:00 - 06:00'
    WHEN HOUR(order_time) BETWEEN 6  AND 7  THEN '06:00 - 08:00'
    WHEN HOUR(order_time) BETWEEN 8  AND 9  THEN '08:00 - 10:00'
    WHEN HOUR(order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
    WHEN HOUR(order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
    WHEN HOUR(order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
    WHEN HOUR(order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
    WHEN HOUR(order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
    WHEN HOUR(order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
    WHEN HOUR(order_time) BETWEEN 22 AND 23 THEN '22:00 - 24:00'
  END AS time_slot,
  COUNT(*) AS total_orders
FROM orders
GROUP BY time_slot
ORDER BY total_orders DESC;
```
Approach 2: Dynamic CONCAT & FLOOR

```sql
SELECT
  CONCAT(
    LPAD(FLOOR(HOUR(order_time) / 2) * 2, 2, '0'), ':00',
    ' - ',
    LPAD(FLOOR(HOUR(order_time) / 2) * 2 + 2, 2, '0'), ':00'
  ) AS time_slot,
  COUNT(*) AS total_orders
FROM orders
GROUP BY time_slot
ORDER BY total_orders DESC;
```
Approach 3: Numeric Slot Index

```sql
SELECT
  FLOOR(HOUR(order_time) / 2) AS slot_index,
  COUNT(*) AS total_orders
FROM orders
GROUP BY slot_index
ORDER BY total_orders DESC;
```

## Q4. Average Order Value for High‑Volume Customers

**Description:**  
Compute the average order value (AOV) for each customer who has placed **more than 200** orders.
```sql
SELECT
  c.customer_name,
  COUNT(o.order_id) AS total_orders,
  ROUND(AVG(o.total_amount), 0) AS average_order_value
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
GROUP BY
  c.customer_name
HAVING
  total_orders > 200
ORDER BY
  total_orders DESC;
```
## Q5. Big‑Spender Customers

**Description:**  
List customers who have spent **more than 50,000** in total.

```sql
SELECT
  c.customer_name,
  COUNT(o.order_id) AS total_orders,
  ROUND(SUM(o.total_amount), 0) AS total_spent
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
GROUP BY
  c.customer_name
HAVING
  total_spent > 50000
ORDER BY
  total_spent DESC;
  ```
## Q6. Orders without Delivery

**Description:**  
Identify orders that were placed but **not delivered**. Return the restaurant name, city, and the number of such undelivered orders.
```sql
SELECT 
    r.restaurant_name, 
    r.city, 
    count(*) not_deliver_orders 
FROM restaurants r 
RIGHT JOIN orders o ON r.restaurant_id = o.restaurant_id  
LEFT JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_status = 'Not Delivered' 
GROUP BY 1,2 
ORDER BY 3 DESC;
```
## Q7. Restaurant Revenue Ranking

**Description:**  
Rank restaurants based on total revenue from the last year. Return their name, total revenue, and rank within their city.
```sql
WITH ranking_table AS (
	SELECT r.city, r.restaurant_name, ROUND(SUM(o.total_amount), 0) total_revenue,
		RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS ranks  
	FROM restaurants r 
	RIGHT JOIN orders o ON r.restaurant_id = o.restaurant_id 
	WHERE o.order_date >= DATE_SUB('2024-03-31', INTERVAL 1 YEAR) 
	GROUP BY 1, 2
)
SELECT * 
FROM ranking_table 
WHERE ranks = 1 
ORDER BY total_revenue DESC;
```
## Q8. Most Popular Dish by City

**Description:**  
Identify the most popular dish in each city based on the number of orders.
```sql
WITH ranking_table AS (
	SELECT r.city, o.order_item AS dish, COUNT(o.order_id) AS orders, 
		RANK() OVER(PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS ranks
	FROM orders o 
	JOIN restaurants r ON o.restaurant_id = r.restaurant_id
	GROUP BY r.city, o.order_item
)
SELECT * 
FROM ranking_table 
WHERE ranks = 1;
```
## Q9. Yearly Customer Churn 

**Description:**  
- Find customers who placed orders in 2023 but not in 2024.
```sql
-- Customers who ordered in 2023 but not 2024
SELECT DISTINCT customer_id 
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023 AND customer_id IS NOT NULL 
	AND customer_id NOT IN (
		SELECT DISTINCT customer_id 
		FROM orders 
		WHERE EXTRACT(YEAR FROM order_date) = 2024 AND customer_id IS NOT NULL
	);
```
## Q10. Financial Yearly Customer Churn

**Description:**  
- Identify customers active in Financial Year 2023-24 but inactive in Financial Year 2024-25.

```sql
-- Customers active in 2023-24 but inactive in 2024-25
SELECT DISTINCT customer_id 
FROM orders
WHERE order_date BETWEEN '2023-04-01' AND '2024-03-31'
	AND customer_id NOT IN (
		SELECT DISTINCT customer_id 
		FROM orders 
		WHERE order_date BETWEEN '2024-04-01' AND '2025-03-31'
	);
```

## Q11. Cancellation Rate Comparison

**Description:**  
Compare each restaurant’s cancellation rate over three consecutive years and categorize the churn trend.
```sql
WITH cancelation_2023 AS (
	SELECT r.restaurant_name, r.city, o.restaurant_id,
		COUNT(d.delivery_id) AS total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) / COUNT(d.delivery_id)) * 100, 2) AS churn_ratio
	FROM deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2022-04-01' AND '2023-03-31'
	GROUP BY o.restaurant_id
	HAVING not_delivered_orders > 0
),
cancelation_2024 AS (
	SELECT r.restaurant_name, r.city, o.restaurant_id,
		COUNT(d.delivery_id) AS total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) / COUNT(d.delivery_id)) * 100, 2) AS churn_ratio
	FROM deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2023-04-01' AND '2024-03-31'
	GROUP BY o.restaurant_id
	HAVING not_delivered_orders > 0
),
cancelation_2025 AS (
	SELECT r.restaurant_name, r.city, o.restaurant_id,
		COUNT(d.delivery_id) AS total_order,
		COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) AS not_delivered_orders,
		ROUND((COUNT(CASE WHEN d.delivery_status = 'Not Delivered' THEN 1 END) / COUNT(d.delivery_id)) * 100, 2) AS churn_ratio
	FROM deliveries d 
	LEFT JOIN orders o ON d.order_id = o.order_id
	LEFT JOIN restaurants r ON o.restaurant_id = r.restaurant_id 
	WHERE order_date BETWEEN '2024-04-01' AND '2025-03-31'
	GROUP BY o.restaurant_id
	HAVING not_delivered_orders > 0
)

SELECT 
	l.restaurant_name, 
	l.city, 
	l.churn_ratio AS churn_2023, 
	c.churn_ratio AS churn_2024, 
	r.churn_ratio AS churn_2025,
	CASE 
		WHEN r.churn_ratio > c.churn_ratio AND c.churn_ratio > l.churn_ratio THEN 'Consistently Increased'
		WHEN c.churn_ratio > l.churn_ratio AND r.churn_ratio < c.churn_ratio THEN 'Decreased This Year'
		WHEN r.churn_ratio > c.churn_ratio AND c.churn_ratio < l.churn_ratio THEN 'Increased This Year'
		WHEN r.churn_ratio < c.churn_ratio AND c.churn_ratio < l.churn_ratio THEN 'Consistently Decreased'
		ELSE 'Fluctuating or Stable'
	END AS churn_trend
FROM cancelation_2023 l 
JOIN cancelation_2024 c ON l.restaurant_id = c.restaurant_id 
JOIN cancelation_2025 r ON c.restaurant_id = r.restaurant_id;
```
## Q12. Rider Average Delivery Time

**Description:**  
Determine each rider’s average delivery time in minutes for completed deliveries.
```sql 
SELECT 
    r.rider_name, 
    COUNT(o.order_id) AS order_count,
    ROUND(AVG(
        TIME_TO_SEC(
            IF(d.delivery_time < o.order_time, 
                TIMEDIFF(ADDTIME(d.delivery_time, '24:00:00'), o.order_time), 
                TIMEDIFF(d.delivery_time, o.order_time)
            )
        ) / 60), 0) AS average_delivery_minutes
FROM riders r 
JOIN deliveries d ON d.rider_id = r.rider_id 
JOIN orders o ON o.order_id = d.order_id 
WHERE o.order_status = 'Completed'
GROUP BY r.rider_id
ORDER BY average_delivery_minutes;
```
## Q13. Monthly Restaurant Growth Ratio

**Description:**  
Calculate each restaurant’s **month-over-month growth ratio** based on completed orders.
```sql
WITH monthly_orders AS (
    SELECT 
        o.restaurant_id, 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
        COUNT(o.order_id) AS curr_month_order
    FROM orders o 
    WHERE o.order_status = 'Completed' 
    GROUP BY o.restaurant_id, month_year
)
SELECT 
    restaurant_id,
    month_year,
    LAG(curr_month_order) OVER (PARTITION BY restaurant_id ORDER BY month_year) AS prev_month_order,
    curr_month_order,
    ((curr_month_order - LAG(curr_month_order) OVER (PARTITION BY restaurant_id ORDER BY month_year)) / curr_month_order) * 100 AS growth_ratio
FROM monthly_orders 
ORDER BY month_year;
```
## Q14. Customer Segmentation

**Description:**  
Segment customers into **Gold** or **Silver** based on whether their monthly spending is above or below the **average order value (AOV)**.
```sql
SELECT 
    cx_category, 
    SUM(orders) AS total_orders, 
    SUM(total_spent) AS total_spent 
FROM (
    SELECT 
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS month_year,
        ROUND(SUM(total_amount), 0) AS total_spent,
        COUNT(order_id) AS orders,
        CASE 
            WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold' 
            ELSE 'Silver' 
        END AS cx_category
    FROM orders
    GROUP BY customer_id, month_year
) AS t1 
GROUP BY cx_category;
```
## Q15. Rider Monthly Earning

**Description:**  
Calculate each **rider’s monthly earnings**, assuming they earn **8%** of the order value.
```sql
SELECT 
    d.rider_id, 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
    COUNT(o.order_id) AS orders, 
    ROUND(SUM(o.total_amount), 0) AS total_revenue, 
    ROUND(SUM(o.total_amount) * 0.08, 0) AS riders_earning
FROM deliveries d 
JOIN orders o ON o.order_id = d.order_id
WHERE d.rider_id <> 0
GROUP BY d.rider_id, month_year
ORDER BY d.rider_id, month_year;
```
## Q16. Rider Rating Analysis

**Description:**  
Assign star ratings to riders based on delivery time:

- Less than 15 minutes → ⭐⭐⭐⭐⭐  
- Between 15 and 20 minutes → ⭐⭐⭐⭐  
- Exactly 20 minutes → ⭐⭐⭐

```sql
SELECT rider_id, rating, COUNT(*) AS total_stars 
FROM (
    SELECT 
        t.rider_id, 
        t.time_in_minutes,
        CASE 
            WHEN t.time_in_minutes < 15 THEN '5 STAR'
            WHEN t.time_in_minutes BETWEEN 15 AND 20 THEN '4 STAR'
            ELSE '3 STAR' 
        END AS rating 
    FROM (
        SELECT 
            d.rider_id, 
            ROUND(MOD(TIMESTAMPDIFF(SECOND, o.order_time, d.delivery_time) + 86400, 86400) / 60, 2) AS time_in_minutes
        FROM orders o 
        JOIN deliveries d ON o.order_id = d.order_id 
        WHERE d.delivery_status = 'Delivered'
    ) AS t 
) AS s 
GROUP BY rider_id, rating 
ORDER BY rider_id, total_stars DESC;
```
## Q17. Order Frequency by Day  

**Description:**  
Determine the **peak ordering day** for each restaurant based on order frequency.
```sql
SELECT * FROM 
	( SELECT 
		r.restaurant_name, 
		DAYNAME(order_date) AS day_name, 
		COUNT(o.order_id) AS total_order,
		RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as ranking
	FROM orders o JOIN restaurants r on o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
    ) as t1 
WHERE ranking = 1;
```
## Q18. Customer Lifetime Value (CLV)

**Description:**  
Calculate the **total revenue generated** by **each customer** 
over all their completed orders.
```sql
SELECT 
	o.customer_id,
	c.customer_name,
    COUNT(o.order_id) AS total_order,
    ROUND(SUM(o.total_amount),0) AS total_revenue
FROM orders o 
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY 1;
```
## Q19. Monthly Sales Trend
**Description:**  
Identify the **monthly sales trend** by comparing each month's total sales to the previous month.
```sql
SELECT 
	DATE_FORMAT(order_date, '%Y-%m') AS year_months,
	ROUND(LAG(SUM(total_amount),1) OVER(ORDER BY DATE_FORMAT(order_date, '%Y-%m')),0) AS prev_month_sale,
	ROUND(SUM(total_amount),0) AS current_total_sale,
	CASE 
		WHEN SUM(total_amount) > LAG(SUM(total_amount),1) OVER(ORDER BY DATE_FORMAT(order_date, '%Y-%m')) THEN '▲ Up Trend' 
		ELSE '▼ Down Trend' 
	END AS trend_status
FROM orders
WHERE order_status = 'Completed'
GROUP BY 1;
```
## Q20. Rider Efficiency
**Description:**  
Evaluate rider efficiency by comparing **average delivery time** across all riders.
```sql
SELECT 
	MIN(time_in_minutes) AS min_avg_delivery_time,
	MAX(time_in_minutes) AS max_avg_delivery_time 
FROM (
	SELECT 
		d.rider_id,
		ROUND(AVG(MOD(TIMESTAMPDIFF(SECOND, o.order_time, d.delivery_time) + 86400, 86400) / 60), 0) AS time_in_minutes
	FROM orders o 
	JOIN deliveries d ON o.order_id = d.order_id 
	WHERE d.delivery_status = 'Delivered' AND d.rider_id <> 0
	GROUP BY 1
) AS t1;
```
## Q21. Order Item Popularity
**Description:**  
Identify the top 3 most ordered items by season to spot seasonal demand trends.
```sql
SELECT order_item, season, total_orders 
FROM (
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
	ORDER BY season, total_orders DESC
) AS t2 
WHERE item_rank <= 3;
```
## Q22. City Revenue Ranking (2023)
**Description:**  
Rank each city based on the **total revenue** generated in the year **2023**.
```sql
SELECT 
	r.city, 
	ROUND(SUM(o.total_amount),0) AS total_revenue, 
	RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS ranking
FROM orders o 
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE YEAR(o.order_date) = 2023 
GROUP BY 1;
```
## Q23. Quarterly Active Customers
**Description:**  
Count unique active customers each quarter.
```sql
SELECT 
    CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) AS quarter,
    COUNT(DISTINCT customer_id) AS customer_count,
    GROUP_CONCAT(DISTINCT customer_id ORDER BY customer_id SEPARATOR ', ') AS customer_ids
FROM orders
WHERE order_status = 'Completed'
GROUP BY quarter
ORDER BY quarter;
```
## Q24. Quarterly Customer Churn
**Description:**  
Identify customers who became inactive in the following quarter.
```sql
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
```
## Q25. Yearly Customer Churn
**Description:**  
Find customers who stopped ordering for over a year or never returned.
```sql
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
```
---
**-- END OF REPORT --**
---
