USE olist_project;

-- ============================================
-- Business Question 1
-- 1. Which product categories generate high revenue but low satisfaction?
-- ============================================
SELECT
	ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM cleaned_orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
JOIN reviews r
ON o.order_id = r.order_id
GROUP BY category
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY total_revenue DESC, avg_review_score ASC;

-- ============================================
-- Business Question 2
-- 2. What is the average review score by delivery performance?
-- ============================================
SELECT 
	o.delivery_Status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score),2) AS avg_review_score
FROM cleaned_orders o
JOIN reviews r
ON o.order_id = r.order_id
GROUP BY o.delivery_status
ORDER BY avg_review_score;

-- ============================================
-- Business Question 3
-- 3. What is the average review score?
-- ============================================
SELECT 
	COUNT(DISTINCT o.order_id),
	ROUND(AVG(r.review_score),2) AS avg_review_score
FROM cleaned_orders o
JOIN reviews r
ON o.order_id = r.order_id;

-- ============================================
-- Business Question 4
-- 4. Which products have the highest number of negative reviews?
-- ============================================
SELECT 
	ct.product_category_name_english AS category,
    COUNT(*) AS negative_reviews
FROM cleaned_orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
ON p.product_category_name = ct.product_category_name
JOIN reviews r
ON o.order_id = r.order_id
WHERE r.review_score <= 2
GROUP BY category
ORDER BY negative_reviews DESC;

