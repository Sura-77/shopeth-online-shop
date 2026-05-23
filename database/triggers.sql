-- ============================================================
--  Online Shop System — Triggers (triggers.sql)
--  4 triggers covering inventory, order totals, and data safety
-- ============================================================

USE online_shop_db;

DELIMITER $$

-- ============================================================
-- TRIGGER 1: trg_deduct_inventory_after_order_item
-- Fires AFTER an order_item row is inserted.
-- Automatically deducts quantity_in_stock for that product.
--
-- Why: Even if PlaceOrder() deducts stock in bulk,
-- this trigger acts as a safety net — if order_items
-- are ever inserted directly (e.g. admin tools, future
-- API routes), stock stays consistent automatically.
-- ============================================================
DROP TRIGGER IF EXISTS trg_deduct_inventory_after_order_item$$
CREATE TRIGGER trg_deduct_inventory_after_order_item
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET    quantity_in_stock = quantity_in_stock - NEW.quantity
    WHERE  product_id = NEW.product_id;
END$$

-- ============================================================
-- TRIGGER 2: trg_restore_inventory_after_order_cancel
-- Fires AFTER an order's status is updated to 'cancelled'
-- or 'refunded'. Restores stock for all items in that order.
--
-- Why: When an order is cancelled, products go back on the
-- shelf. Without this trigger, cancelled orders would
-- permanently reduce inventory.
-- ============================================================
DROP TRIGGER IF EXISTS trg_restore_inventory_after_order_cancel$$
CREATE TRIGGER trg_restore_inventory_after_order_cancel
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Only fire when status changes TO cancelled or refunded
    IF (NEW.order_status IN ('cancelled', 'refunded'))
       AND (OLD.order_status NOT IN ('cancelled', 'refunded')) THEN

        UPDATE inventory inv
        JOIN   order_items oi ON oi.product_id = inv.product_id
        SET    inv.quantity_in_stock = inv.quantity_in_stock + oi.quantity
        WHERE  oi.order_id = NEW.order_id;

    END IF;
END$$

-- ============================================================
-- TRIGGER 3: trg_sync_order_total_on_item_insert
-- Fires AFTER an order_item is inserted.
-- Recalculates and updates orders.total_amount to keep
-- it in sync with the sum of its order_items.subtotals,
-- while preserving any coupon discount already applied.
--
-- Why: orders.total_amount is a denormalized field.
-- This trigger ensures it never drifts out of sync
-- when items are inserted outside of PlaceOrder()
-- (e.g. admin tools, future API routes).
--
-- FIX: The old version blindly overwrote total_amount with
-- the raw SUM(subtotal), erasing any coupon discount that
-- PlaceOrder() had already calculated. The corrected version
-- computes the discount gap from the coupon record and
-- re-applies it so the stored total stays accurate.
-- ============================================================
DROP TRIGGER IF EXISTS trg_sync_order_total_on_item_insert$$
CREATE TRIGGER trg_sync_order_total_on_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_raw_total      DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_discount_type  VARCHAR(20)   DEFAULT NULL;
    DECLARE v_discount_value DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_final_total    DECIMAL(10,2) DEFAULT 0.00;

    -- Sum all subtotals for this order (including the newly inserted row)
    SELECT COALESCE(SUM(subtotal), 0.00)
    INTO   v_raw_total
    FROM   order_items
    WHERE  order_id = NEW.order_id;

    -- Look up the coupon attached to this order (if any)
    SELECT cd.discount_type, cd.discount_value
    INTO   v_discount_type, v_discount_value
    FROM   orders o
    JOIN   coupons_discounts cd ON o.coupon_id = cd.coupon_id
    WHERE  o.order_id = NEW.order_id;

    -- Re-apply the coupon discount so total_amount stays correct
    IF v_discount_type = 'percentage' THEN
        SET v_final_total = v_raw_total - (v_raw_total * v_discount_value / 100);
    ELSEIF v_discount_type = 'fixed' THEN
        SET v_final_total = v_raw_total - v_discount_value;
    ELSE
        -- No coupon on this order
        SET v_final_total = v_raw_total;
    END IF;

    -- Ensure total never goes negative
    IF v_final_total < 0 THEN
        SET v_final_total = 0.00;
    END IF;

    UPDATE orders
    SET    total_amount = v_final_total
    WHERE  order_id = NEW.order_id;
END$$

-- ============================================================
-- TRIGGER 4: trg_prevent_review_without_purchase
-- Fires BEFORE a review is inserted.
-- Blocks the insert if the customer has never ordered
-- that product (i.e. review without a real purchase).
--
-- Why: Enforces the business rule that only verified
-- buyers can review a product. Pure application-layer
-- checks can be bypassed; this enforces it at DB level.
-- ============================================================
DROP TRIGGER IF EXISTS trg_prevent_review_without_purchase$$
CREATE TRIGGER trg_prevent_review_without_purchase
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE v_purchased INT DEFAULT 0;

    SELECT COUNT(*) INTO v_purchased
    FROM   order_items  oi
    JOIN   orders        o  ON oi.order_id   = o.order_id
    WHERE  o.customer_id  = NEW.customer_id
      AND  oi.product_id  = NEW.product_id
      AND  o.order_status NOT IN ('cancelled', 'refunded');

    IF v_purchased = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: You can only review products you have purchased.';
    END IF;
END$$

DELIMITER ;

-- ============================================================
--  VERIFY TRIGGERS WERE CREATED
-- ============================================================
--
--  SHOW TRIGGERS FROM online_shop_db;
--
-- ============================================================
--  HOW TO TEST EACH TRIGGER
-- ============================================================
--
--  TRIGGER 1 — auto deduct stock on order item insert:
--    Check stock before:
--      SELECT quantity_in_stock FROM inventory WHERE product_id = 1;
--    Insert an order item directly:
--      INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
--      VALUES (1, 1, 2, 18500.00, 37000.00);
--    Check stock dropped by 2:
--      SELECT quantity_in_stock FROM inventory WHERE product_id = 1;
--
--  TRIGGER 2 — restore stock on order cancel:
--    Check stock before:
--      SELECT quantity_in_stock FROM inventory WHERE product_id = 4;
--    Cancel the order:
--      UPDATE orders SET order_status = 'cancelled' WHERE order_id = 4;
--    Check stock was restored:
--      SELECT quantity_in_stock FROM inventory WHERE product_id = 4;
--
--  TRIGGER 3 — order total stays in sync:
--    Check total before:
--      SELECT total_amount FROM orders WHERE order_id = 1;
--    Insert an extra item:
--      INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
--      VALUES (1, 2, 1, 8900.00, 8900.00);
--    Verify total updated automatically:
--      SELECT total_amount FROM orders WHERE order_id = 1;
--
--  TRIGGER 4 — block review without purchase:
--    This should FAIL (customer 2 never ordered product 1):
--      INSERT INTO reviews (customer_id, product_id, rating, comment)
--      VALUES (2, 1, 5, 'Great phone!');
--    This should SUCCEED (customer 1 ordered product 1):
--      INSERT INTO reviews (customer_id, product_id, rating, comment)
--      VALUES (1, 1, 5, 'Great phone!');
--    (Will fail on duplicate if already exists in sample_data — delete first to test)
--
-- ============================================================
--  END OF TRIGGERS
-- ============================================================
