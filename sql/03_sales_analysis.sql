USE olist_project;

-- Scope: cleaned_orders (delivered, with an actual delivery date).
-- Customer payments and item value including freight are different measures.

-- 1. Monthly orders, payment value, and average order value.
-- LEFT JOIN retains delivered orders with no payment record in the order count.
WITH payment_by_order AS (
    SELECT order_id, SUM(payment_value) AS payment_value
    FROM payments
    GROUP BY order_id
)
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    ROUND(COALESCE(SUM(p.payment_value), 0), 2) AS total_revenue,
    ROUND(COALESCE(SUM(p.payment_value), 0) / NULLIF(COUNT(*), 0), 2)
        AS average_order_value
FROM cleaned_orders o
LEFT JOIN payment_by_order p ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;

-- 2. Category item value, including freight.
-- NULL category labels remain visible here for reconciliation.
SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_item_value
FROM cleaned_orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY item_revenue DESC;

-- 3. Overall AOV: payment value divided by ALL eligible delivered orders.
WITH payment_by_order AS (
    SELECT order_id, SUM(payment_value) AS payment_value
    FROM payments
    GROUP BY order_id
)
SELECT
    COUNT(*) AS total_orders,
    ROUND(COALESCE(SUM(p.payment_value), 0), 2) AS total_revenue,
    ROUND(COALESCE(SUM(p.payment_value), 0) / NULLIF(COUNT(*), 0), 2)
        AS average_order_value
FROM cleaned_orders o
LEFT JOIN payment_by_order p ON o.order_id = p.order_id;
