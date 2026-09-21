-- Initial setup only: run once after importing into a fresh database.
USE olist_project;

/*=========================================================
OLIST E-COMMERCE DATABASE OPTIMIZATION

Purpose:
- Improve data types
- Define primary keys
- Define foreign keys
- Define unique constraints
- Improve query performance
- Prepare database for SQL analysis & Power BI

=========================================================*/


-- =====================================================
-- STEP 1 : REVIEW CURRENT DATABASE SCHEMA
-- =====================================================

DESCRIBE category_translation;
DESCRIBE customers;
DESCRIBE order_items;
DESCRIBE orders;
DESCRIBE payments;
DESCRIBE products;
DESCRIBE reviews;
DESCRIBE sellers;



-- =====================================================
-- STEP 2 : MODIFY DATA TYPES
-- =====================================================


-- Customers

ALTER TABLE customers
MODIFY customer_id VARCHAR(32),
MODIFY customer_unique_id VARCHAR(32),
MODIFY customer_zip_code_prefix INT,
MODIFY customer_city VARCHAR(100),
MODIFY customer_state VARCHAR(2);



-- Orders

ALTER TABLE orders
MODIFY order_id VARCHAR(32),
MODIFY customer_id VARCHAR(32),
MODIFY order_status VARCHAR(20);



-- Order Items

ALTER TABLE order_items
MODIFY order_id VARCHAR(32),
MODIFY order_item_id TINYINT UNSIGNED,
MODIFY product_id VARCHAR(32),
MODIFY seller_id VARCHAR(32),
MODIFY shipping_limit_date DATETIME,
MODIFY price DECIMAL(10,2),
MODIFY freight_value DECIMAL(10,2);



-- Products

ALTER TABLE products
MODIFY product_id VARCHAR(32),
MODIFY product_category_name VARCHAR(100),
MODIFY product_name_lenght INT,
MODIFY product_description_lenght INT,
MODIFY product_photos_qty TINYINT UNSIGNED,
MODIFY product_weight_g INT,
MODIFY product_length_cm INT,
MODIFY product_height_cm INT,
MODIFY product_width_cm INT;



-- Payments

ALTER TABLE payments
MODIFY order_id VARCHAR(32),
MODIFY payment_sequential TINYINT UNSIGNED,
MODIFY payment_type VARCHAR(20),
MODIFY payment_installments TINYINT UNSIGNED,
MODIFY payment_value DECIMAL(10,2);



-- Reviews

ALTER TABLE reviews
MODIFY review_id VARCHAR(32),
MODIFY order_id VARCHAR(32),
MODIFY review_score TINYINT UNSIGNED;



-- Sellers

ALTER TABLE sellers
MODIFY seller_id VARCHAR(32),
MODIFY seller_zip_code_prefix INT,
MODIFY seller_city VARCHAR(100),
MODIFY seller_state VARCHAR(2);



-- Category Translation

ALTER TABLE category_translation
MODIFY product_category_name VARCHAR(100),
MODIFY product_category_name_english VARCHAR(100);




-- =====================================================
-- STEP 3 : PRIMARY KEYS
-- =====================================================


-- Customers

ALTER TABLE customers
ADD PRIMARY KEY(customer_id);



-- Orders

ALTER TABLE orders
ADD PRIMARY KEY(order_id);



-- Products

ALTER TABLE products
ADD PRIMARY KEY(product_id);



-- Sellers

ALTER TABLE sellers
ADD PRIMARY KEY(seller_id);



-- Order Items
-- Composite PK because:
-- order_id alone is duplicated
-- order_item_id alone is duplicated

ALTER TABLE order_items
ADD PRIMARY KEY(order_id, order_item_id);



-- Payments
-- Composite PK because:
-- one order can have multiple payment records

ALTER TABLE payments
ADD PRIMARY KEY(order_id, payment_sequential);



-- Category Translation

ALTER TABLE category_translation
ADD PRIMARY KEY(product_category_name);



-- Reviews
-- review_id is duplicated
-- create surrogate key

ALTER TABLE reviews
ADD COLUMN review_sk INT AUTO_INCREMENT PRIMARY KEY FIRST;




-- =====================================================
-- STEP 4 : FIX CATEGORY DATA QUALITY ISSUE
-- =====================================================


-- Find missing categories

SELECT DISTINCT
    p.product_category_name

FROM products p

LEFT JOIN category_translation c

ON p.product_category_name = c.product_category_name

WHERE c.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;



-- Insert missing category translations (initial setup)
INSERT INTO category_translation (
    product_category_name,
    product_category_name_english
)
VALUES
    ('pc_gamer', 'pc_gamer'),
    (
        'portateis_cozinha_e_preparadores_de_alimentos',
        'portable_kitchen_food_processors'
    );

-- Verify missing categories again

SELECT DISTINCT
    p.product_category_name

FROM products p

LEFT JOIN category_translation c

ON p.product_category_name = c.product_category_name

WHERE c.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;





-- =====================================================
-- STEP 5 : ADD UNIQUE CONSTRAINTS
-- =====================================================


-- Reviews:
-- Keep original business key
-- Also creates index starting with order_id

ALTER TABLE reviews
ADD CONSTRAINT uq_reviews_order_review
UNIQUE(order_id, review_id);




-- =====================================================
-- STEP 6 : ADD FOREIGN KEYS
-- =====================================================


-- Products -> Category

ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY(product_category_name)
REFERENCES category_translation(product_category_name);



-- Orders -> Customers

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id);



-- Order Items -> Orders

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY(order_id)
REFERENCES orders(order_id);



-- Order Items -> Products

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY(product_id)
REFERENCES products(product_id);



-- Order Items -> Sellers

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_sellers
FOREIGN KEY(seller_id)
REFERENCES sellers(seller_id);



-- Payments -> Orders

ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY(order_id)
REFERENCES orders(order_id);



-- Reviews -> Orders

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY(order_id)
REFERENCES orders(order_id);




-- =====================================================
-- STEP 7 : CREATE INDEXES
-- =====================================================


-- Foreign keys without existing suitable indexes


CREATE INDEX idx_orders_customer_id
ON orders(customer_id);



CREATE INDEX idx_order_items_product_id
ON order_items(product_id);



CREATE INDEX idx_order_items_seller_id
ON order_items(seller_id);



-- Product category filtering

CREATE INDEX idx_products_category
ON products(product_category_name);




-- =====================================================
-- STEP 8 : VERIFY PRIMARY KEYS
-- =====================================================


SHOW INDEX FROM customers
WHERE Key_name='PRIMARY';


SHOW INDEX FROM orders
WHERE Key_name='PRIMARY';


SHOW INDEX FROM order_items
WHERE Key_name='PRIMARY';


SHOW INDEX FROM payments
WHERE Key_name='PRIMARY';


SHOW INDEX FROM products
WHERE Key_name='PRIMARY';


SHOW INDEX FROM reviews
WHERE Key_name='PRIMARY';


SHOW INDEX FROM sellers
WHERE Key_name='PRIMARY';


SHOW INDEX FROM category_translation
WHERE Key_name='PRIMARY';




-- =====================================================
-- STEP 9 : VERIFY FOREIGN KEYS
-- =====================================================


SELECT

TABLE_NAME,

CONSTRAINT_NAME

FROM information_schema.TABLE_CONSTRAINTS

WHERE CONSTRAINT_TYPE='FOREIGN KEY'

AND TABLE_SCHEMA = DATABASE();




-- =====================================================
-- STEP 10 : VERIFY INDEXES
-- =====================================================


SHOW INDEX FROM orders;

SHOW INDEX FROM order_items;

SHOW INDEX FROM payments;

SHOW INDEX FROM products;

SHOW INDEX FROM reviews;

SHOW INDEX FROM category_translation;