USE olist_project;

-- ============================================
-- Business Question 1
-- Which payment methods are most commonly used?
-- Usage is measured by payment-record count.
-- ============================================
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(
        100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM payments), 0),
        2
    ) AS payment_record_percentage
FROM payments
GROUP BY payment_type
ORDER BY payment_records DESC;

-- ============================================
-- Business Question 2
-- Do installment payment records have a higher average value?
-- This compares payment records, not total spending per customer/order.
-- Zero or missing installment counts are classified as Unspecified.
-- ============================================
SELECT
    CASE
        WHEN payment_installments > 1 THEN 'Installment'
        WHEN payment_installments = 1 THEN 'Single Payment'
        ELSE 'Unspecified'
    END AS payment_group,
    COUNT(*) AS payment_records,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_group;

-- ============================================
-- Business Question 3
-- What is the average payment-record value?
-- ============================================
SELECT
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments;

-- ============================================
-- Business Question 4
-- Which methods have the highest payment value per order using that method?
-- Only the amount paid through that method is included in its numerator.
-- An order using multiple methods can belong to several groups.
-- ============================================
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders_using_method,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(
        SUM(payment_value) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS payment_value_per_order
FROM payments
GROUP BY payment_type
ORDER BY payment_value_per_order DESC;
