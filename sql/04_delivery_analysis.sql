USE olist_project;

-- ============================================
-- Business Question 1
-- 1. Which states have the highest late delivery rate?
-- ============================================
SELECT
	c.customer_state,
    COUNT(*) AS total_orders,							
    SUM(CASE WHEN o.delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN o.delivery_status = 'Late' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS late_delivery_rate
FROM cleaned_orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY late_delivery_rate DESC;

-- ============================================
-- Business Question 2
-- 2. Does late delivery affect customer satisfaction?
-- ============================================
SELECT
	O.delivery_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(AVG(r.review_score), 2) AS average_review_score
FROM cleaned_orders o
JOIN reviews r
ON o.order_id = r.order_id
GROUP BY o.delivery_status;

-- ============================================
-- Business Question 3
-- 3. How many deliveries are late compared to on-time?
-- ============================================
SELECT 
	delivery_status,
	COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cleaned_orders), 2) AS percentage
FROM cleaned_orders 
GROUP BY delivery_status;

-- ============================================
-- Business Question 4
-- 4. What is the average delivery time for late vs on-time orders?
-- ============================================

SELECT 
	delivery_status,
	ROUND(AVG(delivery_days),2) AS avg_delivery_days,
    ROUND(AVG(delay_days),2) AS avg_delay_days
FROM cleaned_orders
GROUP BY delivery_status;