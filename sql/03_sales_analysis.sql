USE olist_project;

-- ============================================
-- Business Question 1
-- How has marketplace revenue changed over time?
-- ============================================
SELECT 
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(SUM(p.payment_value),2) AS total_revenue
    FROM cleaned_orders o
    JOIN payments p 
    ON o.order_id = p.order_id
    GROUP BY order_month
    ORDER BY order_month;
    
-- ============================================
-- Business Question 2
-- 2. Which product categories contribute the highest revenue?
-- ============================================
 SELECT 
	ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue,
	ROUND(AVG(oi.price + oi.freight_value),2) AS avg_item_value
FROM cleaned_orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_revenue DESC;

-- ============================================
-- Business Question 3
-- 3. What is the average customer spending per order?
-- ============================================
SELECT 
	ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id),2) AS  average_order_value
FROM cleaned_orders o
JOIN payments p
ON o.order_id = p.order_id
 

