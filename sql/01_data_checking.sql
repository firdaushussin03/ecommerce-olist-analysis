USE olist_project;


SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM order_items;

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM products;

SELECT COUNT(*) FROM payments;

SELECT COUNT(*) FROM reviews;

SELECT COUNT(*) FROM sellers;

SELECT
	COUNT(*) AS total_orders,
	SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date
FROM orders;

SELECT
	order_status,
	COUNT(*) AS total
FROM orders
GROUP BY order_status
ORDER BY total DESC;

SELECT 
	order_id, 
    order_status, 
    order_delivered_customer_date 
FROM orders 
WHERE order_status = 'canceled'
AND order_delivered_customer_date IS NOT NULL;

SELECT 
	order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT 
	order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

SELECT COUNT(*) AS missing_order_id
FROM orders
WHERE order_id IS NULL;

SELECT
	COUNT(*) AS missing_customer
FROM orders o 
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT 
	COUNT(*) AS missing_products
FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*)
FROM orders
WHERE order_status = 'delivered';