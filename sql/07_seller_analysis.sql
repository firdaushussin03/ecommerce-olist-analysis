USE olist_project;

-- ============================================
-- Business Question 1
-- 1. Which sellers generate the highest revenue?
-- ============================================
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN cleaned_orders o
ON oi.order_id = o.order_id
JOIN sellers s
ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================
-- Business Question 2
-- 2. Which sellers generate high revenue but poor customer satisfaction?
-- ============================================
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue,
    ROUND(AVG(r.review_score),2) AS average_customer_satisfaction
FROM order_items oi
JOIN cleaned_orders o
ON oi.order_id = o.order_id
JOIN sellers s
ON oi.seller_id = s.seller_id
JOIN reviews r
ON oi.order_id = r.order_id
GROUP BY
    oi.seller_id,
    s.seller_state
HAVING
    COUNT(DISTINCT oi.order_id) >= 20
    AND AVG(r.review_score) < 3.5
ORDER BY total_revenue DESC;



