-- ============================================================
--  Online Shop System — MySQL Schema v2.0 (schema_v2.sql)
--  All 16 tables | 3NF | PKs, FKs, UNIQUEs, CHECKs, Indexes
--  Improvements over v1:
--    • subtotal/total_amount marked as denormalized + safe guard
--    • CHECK on percentage coupon value (≤ 100)
--    • is_main changed to BOOLEAN
--    • composite index on users(status, deleted_at)
--    • composite index on products(status, deleted_at)
--    • shipping address clarified via comment
--    • minor comment improvements throughout
-- ============================================================

CREATE DATABASE IF NOT EXISTS online_shop_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE online_shop_db;

-- ============================================================
-- 1. ROLES
-- ============================================================
CREATE TABLE roles (
    role_id     INT          AUTO_INCREMENT PRIMARY KEY,
    role_name   VARCHAR(50)  NOT NULL,
    description TEXT,
    CONSTRAINT uq_role_name UNIQUE (role_name)
);

-- ============================================================
-- 2. USERS
-- ============================================================
CREATE TABLE users (
    user_id    INT           AUTO_INCREMENT PRIMARY KEY,
    role_id    INT           NOT NULL,
    username   VARCHAR(50)   NOT NULL,
    email      VARCHAR(100)  NOT NULL,
    password   VARCHAR(255)  NOT NULL,  -- store bcrypt hash, never plaintext
    phone      VARCHAR(20),
    status     ENUM('active', 'inactive', 'banned') NOT NULL DEFAULT 'active',
    created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME      NULL DEFAULT NULL,  -- soft delete: NULL = not deleted

    CONSTRAINT fk_users_role  FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_uname UNIQUE (username)
);

-- Composite index covers: "active users", "non-deleted users", and both combined
CREATE INDEX idx_users_role        ON users(role_id);
CREATE INDEX idx_users_active      ON users(status, deleted_at);

-- ============================================================
-- 3. CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    customer_id   INT         AUTO_INCREMENT PRIMARY KEY,
    user_id       INT         NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    gender        ENUM('male', 'female', 'other') NULL,
    date_of_birth DATE        NULL,

    CONSTRAINT fk_customers_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_customers_user UNIQUE (user_id)  -- one profile per user
);

-- ============================================================
-- 4. CATEGORIES
-- ============================================================
CREATE TABLE categories (
    category_id        INT          AUTO_INCREMENT PRIMARY KEY,
    category_name      VARCHAR(100) NOT NULL,
    description        TEXT,
    -- Self-referencing FK: NULL = top-level category, non-NULL = subcategory
    parent_category_id INT          NULL DEFAULT NULL,

    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL,  -- deleting a parent promotes children to top-level
    CONSTRAINT uq_category_name UNIQUE (category_name)
);

CREATE INDEX idx_categories_parent ON categories(parent_category_id);

-- ============================================================
-- 5. PRODUCTS
-- ============================================================
CREATE TABLE products (
    product_id   INT            AUTO_INCREMENT PRIMARY KEY,
    category_id  INT            NOT NULL,
    product_name VARCHAR(150)   NOT NULL,
    description  TEXT,
    price        DECIMAL(10,2)  NOT NULL,
    sku          VARCHAR(100)   NOT NULL,
    status       ENUM('active', 'inactive', 'discontinued') NOT NULL DEFAULT 'active',
    created_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at   DATETIME       NULL DEFAULT NULL,  -- soft delete

    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT uq_products_sku      UNIQUE (sku),
    CONSTRAINT chk_products_price   CHECK (price >= 0)
);

-- Composite index covers soft-delete + status filters together
CREATE INDEX idx_products_category   ON products(category_id);
CREATE INDEX idx_products_active     ON products(status, deleted_at);

-- ============================================================
-- 6. PRODUCT_IMAGES
-- ============================================================
CREATE TABLE product_images (
    image_id   INT           AUTO_INCREMENT PRIMARY KEY,
    product_id INT           NOT NULL,
    image_url  VARCHAR(500)  NOT NULL,
    -- BOOLEAN = TINYINT(1) internally; clearer intent than raw TINYINT
    is_main    BOOLEAN       NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_pimages_product FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_pimages_product ON product_images(product_id);

-- ============================================================
-- 7. INVENTORY
-- ============================================================
CREATE TABLE inventory (
    inventory_id      INT      AUTO_INCREMENT PRIMARY KEY,
    product_id        INT      NOT NULL,
    quantity_in_stock INT      NOT NULL DEFAULT 0,
    reorder_level     INT      NOT NULL DEFAULT 10,
    last_updated      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_product  FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_inventory_product  UNIQUE (product_id),  -- one record per product
    CONSTRAINT chk_inventory_qty     CHECK (quantity_in_stock >= 0),
    CONSTRAINT chk_inventory_reorder CHECK (reorder_level >= 0)
);

-- ============================================================
-- 8. COUPONS_DISCOUNTS
-- ============================================================
CREATE TABLE coupons_discounts (
    coupon_id        INT           AUTO_INCREMENT PRIMARY KEY,
    coupon_code      VARCHAR(50)   NOT NULL,
    discount_type    ENUM('percentage', 'fixed') NOT NULL,
    discount_value   DECIMAL(10,2) NOT NULL,
    start_date       DATE          NOT NULL,
    end_date         DATE          NOT NULL,
    min_order_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status           ENUM('active', 'inactive', 'expired') NOT NULL DEFAULT 'active',

    CONSTRAINT uq_coupon_code        UNIQUE (coupon_code),
    CONSTRAINT chk_coupon_value      CHECK (discount_value > 0),
    -- Prevent nonsensical percentage values (e.g. 150%)
    CONSTRAINT chk_coupon_pct        CHECK (
        discount_type = 'fixed' OR discount_value <= 100.00
    ),
    CONSTRAINT chk_coupon_dates      CHECK (end_date >= start_date),
    CONSTRAINT chk_coupon_min_amount CHECK (min_order_amount >= 0)
);

-- ============================================================
-- 9. ADDRESSES
-- ============================================================
CREATE TABLE addresses (
    address_id   INT          AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT          NOT NULL,
    street       VARCHAR(255) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    region       VARCHAR(100),
    postal_code  VARCHAR(20),
    country      VARCHAR(100) NOT NULL,
    address_type ENUM('billing', 'shipping', 'both') NOT NULL DEFAULT 'both',

    CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_addresses_customer ON addresses(customer_id);

-- ============================================================
-- 10. CARTS
-- ============================================================
CREATE TABLE carts (
    cart_id     INT      AUTO_INCREMENT PRIMARY KEY,
    customer_id INT      NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      ENUM('active', 'converted', 'abandoned') NOT NULL DEFAULT 'active',

    CONSTRAINT fk_carts_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_carts_customer ON carts(customer_id);
CREATE INDEX idx_carts_status   ON carts(status);

-- ============================================================
-- 11. CART_ITEMS
-- ============================================================
CREATE TABLE cart_items (
    cart_item_id INT           AUTO_INCREMENT PRIMARY KEY,
    cart_id      INT           NOT NULL,
    product_id   INT           NOT NULL,
    quantity     INT           NOT NULL DEFAULT 1,
    unit_price   DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_citems_cart    FOREIGN KEY (cart_id)    REFERENCES carts(cart_id)    ON DELETE CASCADE,
    CONSTRAINT fk_citems_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT uq_cart_product   UNIQUE (cart_id, product_id),  -- no duplicate product rows in cart
    CONSTRAINT chk_citems_qty    CHECK (quantity > 0),
    CONSTRAINT chk_citems_price  CHECK (unit_price >= 0)
);

CREATE INDEX idx_citems_product ON cart_items(product_id);

-- ============================================================
-- 12. ORDERS
-- ============================================================
CREATE TABLE orders (
    order_id      INT           AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT           NOT NULL,
    address_id    INT           NOT NULL,  -- delivery address (from customer's saved addresses)
    coupon_id     INT           NULL DEFAULT NULL,
    order_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Denormalized total for read performance.
    -- Must equal SUM(order_items.subtotal) minus coupon discount.
    -- Keep in sync via application logic on every insert/update to order_items.
    total_amount  DECIMAL(10,2) NOT NULL,
    order_status  ENUM('pending', 'confirmed', 'processing',
                       'shipped', 'delivered', 'cancelled', 'refunded')
                               NOT NULL DEFAULT 'pending',

    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_address  FOREIGN KEY (address_id)  REFERENCES addresses(address_id),
    CONSTRAINT fk_orders_coupon   FOREIGN KEY (coupon_id)   REFERENCES coupons_discounts(coupon_id)
                                  ON DELETE SET NULL,
    CONSTRAINT chk_orders_amount  CHECK (total_amount >= 0)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status   ON orders(order_status);
CREATE INDEX idx_orders_date     ON orders(order_date);

-- ============================================================
-- 13. ORDER_ITEMS
-- ============================================================
CREATE TABLE order_items (
    order_item_id INT           AUTO_INCREMENT PRIMARY KEY,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    quantity      INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    -- Denormalized: subtotal = quantity * unit_price.
    -- Stored to preserve the exact transaction value even if product price changes later.
    -- Application must set subtotal = quantity * unit_price on every write.
    subtotal      DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_oitems_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id)   ON DELETE CASCADE,
    CONSTRAINT fk_oitems_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_oitems_qty    CHECK (quantity > 0),
    CONSTRAINT chk_oitems_price  CHECK (unit_price >= 0),
    CONSTRAINT chk_oitems_sub    CHECK (subtotal >= 0)
);

CREATE INDEX idx_oitems_order   ON order_items(order_id);
CREATE INDEX idx_oitems_product ON order_items(product_id);

-- ============================================================
-- 14. PAYMENTS
-- ============================================================
CREATE TABLE payments (
    payment_id            INT           AUTO_INCREMENT PRIMARY KEY,
    order_id              INT           NOT NULL,
    payment_method        ENUM('cash', 'credit_card', 'debit_card',
                               'mobile_money', 'bank_transfer') NOT NULL,
    payment_date          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount                DECIMAL(10,2) NOT NULL,
    payment_status        ENUM('pending', 'completed', 'failed', 'refunded')
                                        NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(100)  NULL,

    CONSTRAINT fk_payments_order  FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_payments_order  UNIQUE (order_id),  -- one payment record per order
    CONSTRAINT chk_payments_amount CHECK (amount >= 0)
);

-- ============================================================
-- 15. SHIPPING
-- ============================================================
-- Note: delivery address is not stored here directly.
-- It is inherited from orders.address_id, keeping a single source of truth.
CREATE TABLE shipping (
    shipping_id     INT          AUTO_INCREMENT PRIMARY KEY,
    order_id        INT          NOT NULL,
    courier_name    VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100) NULL,
    shipping_status ENUM('preparing', 'shipped', 'in_transit',
                         'out_for_delivery', 'delivered', 'returned')
                                 NOT NULL DEFAULT 'preparing',
    shipped_date    DATETIME     NULL DEFAULT NULL,
    delivered_date  DATETIME     NULL DEFAULT NULL,

    CONSTRAINT fk_shipping_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_shipping_order UNIQUE (order_id)  -- one shipping record per order
);

CREATE INDEX idx_shipping_status ON shipping(shipping_status);

-- ============================================================
-- 16. REVIEWS
-- ============================================================
CREATE TABLE reviews (
    review_id   INT      AUTO_INCREMENT PRIMARY KEY,
    customer_id INT      NOT NULL,
    product_id  INT      NOT NULL,
    rating      TINYINT  NOT NULL,
    comment     TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reviews_customer   FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reviews_product    FOREIGN KEY (product_id)  REFERENCES products(product_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_review_per_product UNIQUE (customer_id, product_id),  -- one review per product per customer
    CONSTRAINT chk_reviews_rating    CHECK (rating BETWEEN 1 AND 5)
);

CREATE INDEX idx_reviews_product ON reviews(product_id);

-- ============================================================
--  END OF SCHEMA v2.0
-- ============================================================

SHOW DATABASES;
