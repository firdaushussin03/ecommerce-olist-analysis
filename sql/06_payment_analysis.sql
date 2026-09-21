USE olist_project;

-- All queries use payments belonging to cleaned_orders.
-- Payment-record counts and distinct-order counts are labelled separately.

-- 1. Payment method usage and revenue.
WITH delivered_payments AS (
    SELECT p.*
    FROM payments p
    JOIN cleaned_orders o ON p.order_id = o.order_id
)
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders_using_method,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(100.0 * COUNT(*) / NULLIF(
        (SELECT COUNT(*) FROM delivered_payments), 0
    ), 2) AS payment_record_percentage
FROM delivered_payments
GROUP BY payment_type
ORDER BY payment_records DESC;

-- 2. Average payment-record value by installment group.
-- Zero or missing installment counts are unspecified, not installments.
SELECT
    CASE
        WHEN p.payment_installments > 1 THEN 'Installment'
        WHEN p.payment_installments = 1 THEN 'Single Payment'
        ELSE 'Unspecified'
    END AS payment_group,
    COUNT(*) AS payment_records,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value
FROM payments p
JOIN cleaned_orders o ON p.order_id = o.order_id
GROUP BY payment_group;

-- 3. Average payment-record value across delivered-order payments.
SELECT
    COUNT(*) AS payment_records,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value
FROM payments p
JOIN cleaned_orders o ON p.order_id = o.order_id;

-- 4. Compare payment-record averages with method-specific value per order.
-- Only amounts paid through the named method enter its numerator.
SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS orders_using_method,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(AVG(p.payment_value), 2) AS average_payment_value,
    ROUND(SUM(p.payment_value) / NULLIF(COUNT(DISTINCT p.order_id), 0), 2)
        AS payment_value_per_order
FROM payments p
JOIN cleaned_orders o ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY average_payment_value DESC;

-- 5. Mutually exclusive order-level classification, matching the PBI donut.
-- Denominator: delivered orders WITH payment records.
-- 'No installments' means no record has installments > 1; it is not a claim
-- that every order has exactly one payment record or a known installment count.
WITH payment_by_order AS (
    SELECT
        p.order_id,
        MAX(CASE WHEN p.payment_installments > 1 THEN 1 ELSE 0 END)
            AS uses_installments
    FROM payments p
    JOIN cleaned_orders o ON p.order_id = o.order_id
    GROUP BY p.order_id
)
SELECT
    CASE WHEN uses_installments = 1 THEN 'Uses installments'
         ELSE 'No installments' END AS order_payment_plan,
    COUNT(*) AS payment_orders,
    ROUND(100.0 * COUNT(*) / NULLIF(
        (SELECT COUNT(*) FROM payment_by_order), 0
    ), 2) AS percentage_of_payment_orders
FROM payment_by_order
GROUP BY uses_installments
ORDER BY uses_installments DESC;
