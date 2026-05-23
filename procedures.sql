-- ============================================================
--  Online Shop System — Stored Procedures (procedures.sql)
--  5 procedures covering the core business workflows
-- ============================================================

USE online_shop_db;

DELIMITER $$

-- ============================================================
-- PROCEDURE 1: PlaceOrder()
-- Converts an active cart into a confirmed order.
-- Steps:
--   1. Validate cart belongs to customer and is active
--   2. Validate all cart items have sufficient stock
--   3. Validate coupon (if provided) is active and conditions met
--   4. Insert into orders
--   5. Copy cart_items → order_items
--   6. Deduct inventory (trigger also fires here as backup)
--   7. Mark cart as converted
--   8. Return the new order_id
-- ============================================================
DROP PROCEDURE IF EXISTS PlaceOrder$$
CREATE PROCEDURE PlaceOrder(
    IN  p_customer_id  INT,
    IN  p_cart_id      INT,
    IN  p_address_id   INT,
    IN  p_coupon_code  VARCHAR(50),   -- pass NULL if no coupon
    OUT p_order_id     INT,
    OUT p_message      VARCHAR(255)
)
BEGIN
    DECLARE v_coupon_id        INT          DEFAULT NULL;
    DECLARE v_discount_type    VARCHAR(20)  DEFAULT NULL;
    DECLARE v_discount_value   DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_min_order        DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_cart_total       DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_final_total      DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_item_count       INT          DEFAULT 0;
    DECLARE v_stock_ok         INT          DEFAULT 0;

    -- Step 1: Confirm cart is active and belongs to this customer
    SELECT COUNT(*) INTO v_item_count
    FROM carts
    WHERE cart_id = p_cart_id
      AND customer_id = p_customer_id
      AND status = 'active';

    IF v_item_count = 0 THEN
        SET p_order_id = NULL;
        SET p_message  = 'ERROR: Cart not found, already converted, or does not belong to this customer.';
        LEAVE PlaceOrder;  -- exit early
    END IF;

    -- Step 2: Check all cart items have enough stock
    SELECT COUNT(*) INTO v_stock_ok
    FROM cart_items ci
    JOIN inventory inv ON ci.product_id = inv.product_id
    WHERE ci.cart_id = p_cart_id
      AND inv.quantity_in_stock < ci.quantity;

    IF v_stock_ok > 0 THEN
        SET p_order_id = NULL;
        SET p_message  = 'ERROR: One or more products do not have sufficient stock.';
        LEAVE PlaceOrder;
    END IF;

    -- Step 3: Calculate raw cart total
    SELECT COALESCE(SUM(quantity * unit_price), 0.00)
    INTO   v_cart_total
    FROM   cart_items
    WHERE  cart_id = p_cart_id;

    IF v_cart_total = 0.00 THEN
        SET p_order_id = NULL;
        SET p_message  = 'ERROR: Cart is empty.';
        LEAVE PlaceOrder;
    END IF;

    -- Step 4: Validate and apply coupon if provided
    IF p_coupon_code IS NOT NULL THEN
        SELECT coupon_id, discount_type, discount_value, min_order_amount
        INTO   v_coupon_id, v_discount_type, v_discount_value, v_min_order
        FROM   coupons_discounts
        WHERE  coupon_code = p_coupon_code
          AND  status      = 'active'
          AND  CURDATE() BETWEEN start_date AND end_date;

        IF v_coupon_id IS NULL THEN
            SET p_order_id = NULL;
            SET p_message  = 'ERROR: Coupon is invalid, expired, or inactive.';
            LEAVE PlaceOrder;
        END IF;

        IF v_cart_total < v_min_order THEN
            SET p_order_id = NULL;
            SET p_message  = CONCAT('ERROR: Order total must be at least ', v_min_order, ' to use this coupon.');
            LEAVE PlaceOrder;
        END IF;

        -- Apply discount
        IF v_discount_type = 'percentage' THEN
            SET v_final_total = v_cart_total - (v_cart_total * v_discount_value / 100);
        ELSE
            SET v_final_total = v_cart_total - v_discount_value;
        END IF;

        -- Total can never go below zero
        IF v_final_total < 0 THEN
            SET v_final_total = 0.00;
        END IF;
    ELSE
        SET v_final_total = v_cart_total;
    END IF;

    -- Step 5: Everything valid — wrap in a transaction
    START TRANSACTION;

        -- Insert the order
        INSERT INTO orders (customer_id, address_id, coupon_id, total_amount, order_status)
        VALUES (p_customer_id, p_address_id, v_coupon_id, v_final_total, 'pending');

        SET p_order_id = LAST_INSERT_ID();

        -- Copy cart items to order_items.
        -- NOTE: trg_deduct_inventory_after_order_item fires AFTER each INSERT here
        -- and handles the stock deduction automatically. Do NOT deduct stock manually
        -- here as well — that would cause a double-deduction and violate the
        -- CHECK (quantity_in_stock >= 0) constraint.
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
        SELECT p_order_id,
               product_id,
               quantity,
               unit_price,
               quantity * unit_price
        FROM   cart_items
        WHERE  cart_id = p_cart_id;

        -- Mark cart as converted
        UPDATE carts
        SET    status = 'converted'
        WHERE  cart_id = p_cart_id;

    COMMIT;

    SET p_message = CONCAT('SUCCESS: Order #', p_order_id, ' placed. Total: ', v_final_total, ' ETB.');
END$$

-- ============================================================
-- PROCEDURE 2: AddToCart()
-- Adds a product to a customer's active cart.
-- If no active cart exists, creates one first.
-- If the product is already in the cart, increases quantity.
-- ============================================================
DROP PROCEDURE IF EXISTS AddToCart$$
CREATE PROCEDURE AddToCart(
    IN  p_customer_id INT,
    IN  p_product_id  INT,
    IN  p_quantity    INT,
    OUT p_message     VARCHAR(255)
)
BEGIN
    DECLARE v_cart_id      INT           DEFAULT NULL;
    DECLARE v_product_price DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_stock        INT           DEFAULT 0;
    DECLARE v_existing_qty INT           DEFAULT 0;

    -- Validate product is active and get price
    SELECT price INTO v_product_price
    FROM   products
    WHERE  product_id = p_product_id
      AND  status     = 'active'
      AND  deleted_at IS NULL;

    IF v_product_price IS NULL THEN
        SET p_message = 'ERROR: Product not found or is unavailable.';
        LEAVE AddToCart;
    END IF;

    -- Check stock availability
    SELECT quantity_in_stock INTO v_stock
    FROM   inventory
    WHERE  product_id = p_product_id;

    IF v_stock < p_quantity THEN
        SET p_message = CONCAT('ERROR: Only ', v_stock, ' unit(s) in stock.');
        LEAVE AddToCart;
    END IF;

    -- Find or create active cart
    SELECT cart_id INTO v_cart_id
    FROM   carts
    WHERE  customer_id = p_customer_id
      AND  status      = 'active'
    LIMIT 1;

    IF v_cart_id IS NULL THEN
        INSERT INTO carts (customer_id, status) VALUES (p_customer_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- Check if product already in cart
    SELECT quantity INTO v_existing_qty
    FROM   cart_items
    WHERE  cart_id    = v_cart_id
      AND  product_id = p_product_id;

    IF v_existing_qty IS NOT NULL THEN
        -- Update existing row
        UPDATE cart_items
        SET    quantity = quantity + p_quantity
        WHERE  cart_id    = v_cart_id
          AND  product_id = p_product_id;
        SET p_message = CONCAT('SUCCESS: Quantity updated to ', v_existing_qty + p_quantity, '.');
    ELSE
        -- Insert new row
        INSERT INTO cart_items (cart_id, product_id, quantity, unit_price)
        VALUES (v_cart_id, p_product_id, p_quantity, v_product_price);
        SET p_message = 'SUCCESS: Product added to cart.';
    END IF;
END$$

-- ============================================================
-- PROCEDURE 3: GetOrderSummary()
-- Returns full order details: items, payment status,
-- shipping status, coupon used — in one call.
-- ============================================================
DROP PROCEDURE IF EXISTS GetOrderSummary$$
CREATE PROCEDURE GetOrderSummary(
    IN p_order_id INT
)
BEGIN
    -- Order header
    SELECT
        o.order_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        o.order_date,
        o.order_status,
        o.total_amount,
        cd.coupon_code,
        cd.discount_type,
        cd.discount_value,
        CONCAT(a.street, ', ', a.city, ', ', a.country) AS delivery_address
    FROM  orders o
    JOIN  customers c  ON o.customer_id = c.customer_id
    JOIN  addresses a  ON o.address_id  = a.address_id
    LEFT JOIN coupons_discounts cd ON o.coupon_id = cd.coupon_id
    WHERE o.order_id = p_order_id;

    -- Order line items
    SELECT
        oi.order_item_id,
        p.product_name,
        oi.quantity,
        oi.unit_price,
        oi.subtotal
    FROM  order_items oi
    JOIN  products p ON oi.product_id = p.product_id
    WHERE oi.order_id = p_order_id;

    -- Payment info
    SELECT
        payment_method,
        payment_date,
        amount,
        payment_status,
        transaction_reference
    FROM  payments
    WHERE order_id = p_order_id;

    -- Shipping info
    SELECT
        courier_name,
        tracking_number,
        shipping_status,
        shipped_date,
        delivered_date
    FROM  shipping
    WHERE order_id = p_order_id;
END$$

-- ============================================================
-- PROCEDURE 4: UpdateProductStock()
-- Admin manually adjusts stock for a product.
-- Used for restocking, corrections, or writeoffs.
-- ============================================================
DROP PROCEDURE IF EXISTS UpdateProductStock$$
CREATE PROCEDURE UpdateProductStock(
    IN  p_product_id   INT,
    IN  p_new_quantity INT,
    OUT p_message      VARCHAR(255)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    IF p_new_quantity < 0 THEN
        SET p_message = 'ERROR: Quantity cannot be negative.';
        LEAVE UpdateProductStock;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM   inventory
    WHERE  product_id = p_product_id;

    IF v_exists = 0 THEN
        SET p_message = 'ERROR: No inventory record found for this product.';
        LEAVE UpdateProductStock;
    END IF;

    UPDATE inventory
    SET    quantity_in_stock = p_new_quantity
    WHERE  product_id = p_product_id;

    SET p_message = CONCAT('SUCCESS: Stock updated to ', p_new_quantity, ' units.');
END$$

-- ============================================================
-- PROCEDURE 5: GetLowStockProducts()
-- Returns all products where quantity_in_stock <= reorder_level.
-- Used in the admin dashboard to flag restocking needs.
-- ============================================================
DROP PROCEDURE IF EXISTS GetLowStockProducts$$
CREATE PROCEDURE GetLowStockProducts()
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        p.sku,
        i.quantity_in_stock,
        i.reorder_level,
        (i.reorder_level - i.quantity_in_stock) AS units_needed
    FROM  inventory i
    JOIN  products  p ON i.product_id = p.product_id
    WHERE i.quantity_in_stock <= i.reorder_level
      AND p.status    = 'active'
      AND p.deleted_at IS NULL
    ORDER BY units_needed DESC;
END$$

DELIMITER ;

-- ============================================================
--  HOW TO CALL THESE PROCEDURES
-- ============================================================
--
--  1. Place an order:
--     CALL PlaceOrder(1, 2, 1, 'WELCOME10', @order_id, @msg);
--     SELECT @order_id, @msg;
--
--  2. Add to cart:
--     CALL AddToCart(1, 3, 1, @msg);
--     SELECT @msg;
--
--  3. Get full order summary:
--     CALL GetOrderSummary(1);
--
--  4. Admin restock a product:
--     CALL UpdateProductStock(3, 50, @msg);
--     SELECT @msg;
--
--  5. Admin check low stock:
--     CALL GetLowStockProducts();
--
-- ============================================================
--  END OF PROCEDURES
-- ============================================================
