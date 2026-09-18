CREATE OR REPLACE VIEW cleaned_orders AS

SELECT
	o.order_id,
	o.customer_id,
	o.order_purchase_timestamp,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,


	DATEDIFF(
	o.order_delivered_customer_date,
	o.order_purchase_timestamp
	)
	AS delivery_days,


	DATEDIFF(
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date
	)
	AS delay_days,


	CASE
		WHEN o.order_delivered_customer_date >
		o.order_estimated_delivery_date
		THEN 'Late'
		ELSE 'On Time'
	END AS delivery_status
	FROM orders o
	WHERE o.order_status='delivered'
	AND o.order_delivered_customer_date IS NOT NULL;
    
SELECT *
FROM cleaned_orders;

SELECT COUNT(*)
FROM cleaned_orders;

SELECT 
	delivery_status,
    COUNT(*) AS total_orders
FROM cleaned_orders
GROUP BY delivery_status;

SELECT 
	order_id,
    order_status,
    order_delivered_customer_date
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;

SELECT COUNT(*)
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;