USE olist_project;

-- ============================================
-- Business Question 1
-- Which sellers generate the highest item revenue?
-- ============================================
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_revenue
FROM order_items oi
JOIN cleaned_orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_state
ORDER BY item_revenue DESC
LIMIT 10;

-- ============================================
-- Business Question 2
-- Among sellers with at least 20 delivered orders and a review average below
-- 3.5, which generate the highest item revenue?
-- Revenue includes unreviewed orders. The average includes review records only.
-- ============================================
WITH order_seller AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        SUM(oi.price + oi.freight_value) AS item_revenue
    FROM cleaned_orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY oi.order_id, oi.seller_id
),
review_by_order AS (
    SELECT
        order_id,
        SUM(review_score) AS score_sum,
        COUNT(*) AS review_count
    FROM reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
)
SELECT
    os.seller_id,
    s.seller_state,
    COUNT(*) AS total_orders,
    ROUND(SUM(os.item_revenue), 2) AS item_revenue,
    COUNT(r.order_id) AS reviewed_orders,
    ROUND(
        SUM(r.score_sum) / NULLIF(SUM(r.review_count), 0),
        2
    ) AS average_customer_satisfaction
FROM order_seller os
JOIN sellers s ON os.seller_id = s.seller_id
LEFT JOIN review_by_order r ON os.order_id = r.order_id
GROUP BY os.seller_id, s.seller_state
HAVING
    COUNT(*) >= 20
    AND SUM(r.score_sum) / NULLIF(SUM(r.review_count), 0) < 3.5
ORDER BY item_revenue DESC;
