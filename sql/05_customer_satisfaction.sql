USE olist_project;

-- ============================================
-- Business Question 1
-- Which categories have high item revenue and low review scores?
-- Minimum 50 delivered orders; compare scores within the revenue ranking.
-- ============================================
WITH order_category AS (
    SELECT
        oi.order_id,
        ct.product_category_name_english AS category,
        SUM(oi.price + oi.freight_value) AS item_revenue
    FROM cleaned_orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY oi.order_id, ct.product_category_name_english
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
    oc.category,
    COUNT(*) AS total_orders,
    ROUND(SUM(oc.item_revenue), 2) AS item_revenue,
    COUNT(r.order_id) AS reviewed_orders,
    ROUND(
        SUM(r.score_sum) / NULLIF(SUM(r.review_count), 0),
        2
    ) AS avg_review_score
FROM order_category oc
LEFT JOIN review_by_order r ON oc.order_id = r.order_id
GROUP BY oc.category
HAVING COUNT(*) >= 50
ORDER BY item_revenue DESC, avg_review_score ASC;

-- ============================================
-- Business Question 2
-- What is the average review score by delivery performance?
-- The average is per review record; reviewed_orders is a distinct order count.
-- ============================================
SELECT
    o.delivery_status,
    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM cleaned_orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE r.review_score BETWEEN 1 AND 5
GROUP BY o.delivery_status
ORDER BY avg_review_score;

-- ============================================
-- Business Question 3
-- What is the average review score for delivered orders?
-- ============================================
SELECT
    COUNT(DISTINCT o.order_id) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM cleaned_orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE r.review_score BETWEEN 1 AND 5;

-- ============================================
-- Business Question 4
-- Which categories have the most orders with negative reviews?
-- Negative = at least one score of 1 or 2 for the order.
-- Denominator = reviewed orders in the category, not item rows.
-- An order spanning categories can belong to each relevant category.
-- ============================================
WITH order_category AS (
    SELECT DISTINCT
        oi.order_id,
        ct.product_category_name_english AS category
    FROM cleaned_orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
),
review_by_order AS (
    SELECT
        order_id,
        MAX(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
            AS has_negative_review
    FROM reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
)
SELECT
    oc.category,
    COUNT(*) AS reviewed_orders,
    SUM(r.has_negative_review) AS negative_review_orders,
    ROUND(
        100.0 * SUM(r.has_negative_review) / NULLIF(COUNT(*), 0),
        2
    ) AS negative_review_rate
FROM order_category oc
JOIN review_by_order r ON oc.order_id = r.order_id
GROUP BY oc.category
ORDER BY negative_review_orders DESC, reviewed_orders DESC;
