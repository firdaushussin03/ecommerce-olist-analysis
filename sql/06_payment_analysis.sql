USE olist_project;

-- ============================================
-- Business Question 1
-- 1. Which payment methods are most commonly used?
-- ============================================
SELECT
	payment_type,
	COUNT(*) AS transactions,
	ROUND(SUM(payment_value),2) AS total_revenue,
    ROUND(COUNT(*) * 100/ (SELECT COUNT(*) FROM payments),2) AS payment_percentage
FROM payments
GROUP BY payment_type
ORDER BY transactions DESC;

-- ============================================
-- Business Question 2
-- 2. Do customers using installments spend more?
-- ============================================
SELECT
	CASE WHEN payment_installments = 1 THEN 'Single Payment' ELSE 'Installment' END AS payment_group,
	COUNT(*) AS transactions,
	ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_group;

-- ============================================
-- Business Question 3
-- 3. What is average payment value?
-- ============================================
SELECT
	SUM(payment_value) / COUNT(DISTINCT order_id) avg_payment_value
FROM payments;

-- ============================================
-- Business Question 4
-- 4. Which payment methods generate the highest revenue per order?
-- ============================================
SELECT 
	payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value),2) AS total_revenue,
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id),2) AS revenue_per_order
FROM payments 
GROUP BY payment_type
ORDER BY revenue_per_order DESC;