-- ============================================================
--  Online Shop System — Views (views.sql)
--  5 views for common read queries used by the application
-- ============================================================

USE online_shop_db;

-- ============================================================
-- VIEW 1: active_products_view
-- All active, non-deleted products with their category name,
-- main image URL, and current stock level.
-- Used by: product listing pages, search, category browsing.
-- ============================================================
DROP VIEW IF EXISTS active_products_view;
CREATE VIEW active_products_view AS
SELECT
    p.product_id,
    p.product_name,
    p.description,
    p.price,
    p.sku,
    c.category_name,
    parent_cat.category_name  AS parent_category,
    img.image_url             AS main_image_url,
    inv.quantity_in_stock     AS stock,
    CASE
        WHEN inv.quantity_in_stock  = 0                   THEN 'out_of_stock'
        WHEN inv.quantity_in_stock <= inv.reorder_level   THEN 'low_stock'
        ELSE                                                   'in_stock'
    END                       AS stock_status
FROM      products        p
JOIN      categories       c         ON p.category_id        = c.category_id
LEFT JOIN categories       parent_cat ON c.parent_category_id = parent_cat.category_id
LEFT JOIN product_images   img        ON p.product_id         = img.product_id
                                      AND img.is_main         = TRUE
JOIN      inventory        inv        ON p.product_id         = inv.product_id
WHERE     p.status     = 'active'
  AND     p.deleted_at IS NULL;

-- ============================================================
-- VIEW 2: order_summary_view
-- Each order with customer name, item count, totals,
-- payment status, and shipping status in one row.
-- Used by: admin order management, customer order history.
-- ============================================================
DROP VIEW IF EXISTS order_summary_view;
CREATE VIEW order_summary_view AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.customer_id,
    COUNT(oi.order_item_id)                  AS total_items,
    SUM(oi.quantity)                         AS total_units,
    o.total_amount,
    cd.coupon_code,
    pay.payment_status,
    pay.payment_method,
    sh.shipping_status,
    sh.courier_name,
    sh.tracking_number
FROM       orders              o
JOIN       customers           c   ON o.customer_id  = c.customer_id
JOIN       order_items         oi  ON o.order_id     = oi.order_id
LEFT JOIN  coupons_discounts   cd  ON o.coupon_id    = cd.coupon_id
LEFT JOIN  payments            pay ON o.order_id     = pay.order_id
LEFT JOIN  shipping            sh  ON o.order_id     = sh.order_id
GROUP BY
    o.order_id, o.order_date, o.order_status,
    c.first_name, c.last_name, c.customer_id,
    o.total_amount, cd.coupon_code,
    pay.payment_status, pay.payment_method,
    sh.shipping_status, sh.courier_name, sh.tracking_number;

-- ============================================================
-- VIEW 3: low_stock_view
-- Products at or below their reorder level.
-- Used by: admin dashboard stock alert widget.
-- ============================================================
DROP VIEW IF EXISTS low_stock_view;
CREATE VIEW low_stock_view AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    inv.quantity_in_stock,
    inv.reorder_level,
    (inv.reorder_level - inv.quantity_in_stock) AS units_needed
FROM  inventory  inv
JOIN  products   p ON inv.product_id  = p.product_id
JOIN  categories c ON p.category_id   = c.category_id
WHERE inv.quantity_in_stock <= inv.reorder_level
  AND p.status    = 'active'
  AND p.deleted_at IS NULL
ORDER BY units_needed DESC;

-- ============================================================
-- VIEW 4: customer_order_history_view
-- Full purchase history per customer with product details.
-- Used by: customer "My Orders" page.
-- ============================================================
DROP VIEW IF EXISTS customer_order_history_view;
CREATE VIEW customer_order_history_view AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    p.product_id,
    p.product_name,
    img.image_url                            AS product_image,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    sh.shipping_status,
    sh.tracking_number,
    sh.delivered_date
FROM       orders          o
JOIN       customers       c    ON o.customer_id  = c.customer_id
JOIN       order_items     oi   ON o.order_id     = oi.order_id
JOIN       products        p    ON oi.product_id  = p.product_id
LEFT JOIN  product_images  img  ON p.product_id   = img.product_id
                                AND img.is_main   = TRUE
LEFT JOIN  shipping        sh   ON o.order_id     = sh.order_id;

-- ============================================================
-- VIEW 5: product_ratings_view
-- Average rating and review count per product.
-- Used by: product listing (star display), product detail page.
-- ============================================================
DROP VIEW IF EXISTS product_ratings_view;
CREATE VIEW product_ratings_view AS
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.review_id)          AS review_count,
    ROUND(AVG(r.rating), 1)     AS average_rating,
    SUM(r.rating = 5)           AS five_star,
    SUM(r.rating = 4)           AS four_star,
    SUM(r.rating = 3)           AS three_star,
    SUM(r.rating = 2)           AS two_star,
    SUM(r.rating = 1)           AS one_star
FROM       products  p
LEFT JOIN  reviews   r ON p.product_id = r.product_id
WHERE      p.status     = 'active'
  AND      p.deleted_at IS NULL
GROUP BY   p.product_id, p.product_name;

-- ============================================================
--  HOW TO QUERY THESE VIEWS
-- ============================================================
--
--  1. All in-stock products in a category:
--     SELECT * FROM active_products_view
--     WHERE category_name = 'Mobile Phones'
--       AND stock_status  = 'in_stock';
--
--  2. Admin sees all orders with payment + shipping:
--     SELECT * FROM order_summary_view
--     ORDER BY order_date DESC;
--
--  3. Admin dashboard — items needing restock:
--     SELECT * FROM low_stock_view;
--
--  4. Customer's order history:
--     SELECT * FROM customer_order_history_view
--     WHERE customer_id = 1
--     ORDER BY order_date DESC;
--
--  5. Product page ratings:
--     SELECT * FROM product_ratings_view
--     WHERE product_id = 1;
--
--  6. Top rated products:
--     SELECT product_name, average_rating, review_count
--     FROM   product_ratings_view
--     WHERE  review_count >= 1
--     ORDER  BY average_rating DESC, review_count DESC;
--
-- ============================================================
--  END OF VIEWS
-- ============================================================
