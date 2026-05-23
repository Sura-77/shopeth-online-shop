-- ============================================================
--  Online Shop System — Sample Data (sample_data.sql)
--  Covers all 16 tables | Realistic e-commerce data
--  Insert order respects FK dependencies
-- ============================================================

USE online_shop_db;

-- ============================================================
-- 1. ROLES  (3 rows)
-- ============================================================
INSERT INTO roles (role_name, description) VALUES
('admin',    'Full system access — manage products, categories, orders, users'),
('customer', 'Registered buyer — browse, cart, checkout, review'),
('seller',   'Can manage own product listings (future expansion)');

-- ============================================================
-- 2. USERS  (8 rows: 2 admins, 6 customers)
-- ============================================================
-- Passwords are bcrypt hashes of the plaintext shown in the comment
INSERT INTO users (role_id, username, email, password, phone, status) VALUES
-- Admins
(1, 'admin_sara',   'sara@shopAdmin.com',    '$2b$10$exampleHashAdminSara000000000000000000000000000000000', '+251911000001', 'active'),
(1, 'admin_john',   'john@shopAdmin.com',    '$2b$10$exampleHashAdminJohn000000000000000000000000000000000', '+251911000002', 'active'),
-- Customers
(2, 'abel_t',       'abel@email.com',        '$2b$10$exampleHashAbel0000000000000000000000000000000000000', '+251912000001', 'active'),
(2, 'meron_g',      'meron@email.com',       '$2b$10$exampleHashMeron000000000000000000000000000000000000', '+251912000002', 'active'),
(2, 'kaleb_m',      'kaleb@email.com',       '$2b$10$exampleHashKaleb000000000000000000000000000000000000', '+251912000003', 'active'),
(2, 'hana_b',       'hana@email.com',        '$2b$10$exampleHashHana0000000000000000000000000000000000000', '+251912000004', 'active'),
(2, 'dawit_f',      'dawit@email.com',       '$2b$10$exampleHashDawit000000000000000000000000000000000000', '+251912000005', 'active'),
(2, 'tigist_w',     'tigist@email.com',      '$2b$10$exampleHashTigist00000000000000000000000000000000000', '+251912000006', 'inactive');

-- ============================================================
-- 3. CUSTOMERS  (6 rows — one per customer user)
-- ============================================================
INSERT INTO customers (user_id, first_name, last_name, gender, date_of_birth) VALUES
(3, 'Abel',   'Tesfaye',  'male',   '1995-03-14'),
(4, 'Meron',  'Girma',    'female', '1998-07-22'),
(5, 'Kaleb',  'Mulugeta', 'male',   '1993-11-05'),
(6, 'Hana',   'Bekele',   'female', '2000-01-30'),
(7, 'Dawit',  'Fikadu',   'male',   '1990-09-18'),
(8, 'Tigist', 'Wolde',    'female', '1997-04-11');

-- ============================================================
-- 4. CATEGORIES  (10 rows: 4 top-level, 6 sub-categories)
-- ============================================================
INSERT INTO categories (category_name, description, parent_category_id) VALUES
-- Top-level (parent_category_id = NULL)
('Electronics',      'Phones, laptops, accessories and gadgets',      NULL),  -- 1
('Clothing',         'Men and women fashion and apparel',              NULL),  -- 2
('Home & Kitchen',   'Furniture, appliances and home essentials',      NULL),  -- 3
('Books & Stationery', 'Books, pens, notebooks and office supplies',   NULL),  -- 4
-- Sub-categories of Electronics (parent = 1)
('Mobile Phones',    'Smartphones and feature phones',                  1),   -- 5
('Laptops',          'Notebooks and portable computers',                1),   -- 6
-- Sub-categories of Clothing (parent = 2)
('Men\'s Clothing',  'Shirts, trousers, jackets for men',               2),   -- 7
('Women\'s Clothing','Dresses, tops, skirts for women',                 2),   -- 8
-- Sub-categories of Home & Kitchen (parent = 3)
('Kitchen Appliances','Blenders, microwaves, coffee makers',            3),   -- 9
-- Sub-category of Books (parent = 4)
('Stationery',       'Pens, notebooks, folders and office supplies',    4);   -- 10

-- ============================================================
-- 5. PRODUCTS  (12 rows across multiple categories)
-- ============================================================
INSERT INTO products (category_id, product_name, description, price, sku, status) VALUES
-- Mobile Phones (cat 5)
(5, 'Samsung Galaxy A54',   '6.4" AMOLED, 128GB, 5000mAh battery',          18500.00, 'SKU-MOB-001', 'active'),   -- 1
(5, 'Tecno Spark 20',       '6.56" display, 128GB, 5000mAh, dual SIM',        8900.00, 'SKU-MOB-002', 'active'),   -- 2
(5, 'iPhone 14',            '6.1" Super Retina, 128GB, iOS 16',              65000.00, 'SKU-MOB-003', 'active'),   -- 3
-- Laptops (cat 6)
(6, 'HP Pavilion 15',       'Intel i5, 8GB RAM, 512GB SSD, Win 11',          42000.00, 'SKU-LAP-001', 'active'),   -- 4
(6, 'Lenovo IdeaPad 3',     'AMD Ryzen 5, 8GB RAM, 256GB SSD',               35000.00, 'SKU-LAP-002', 'active'),   -- 5
-- Men's Clothing (cat 7)
(7, 'Classic Oxford Shirt', '100% cotton, slim fit, available S-XXL',          850.00, 'SKU-MEN-001', 'active'),   -- 6
(7, 'Chino Trousers',       'Stretch cotton chino, multiple colors',           1200.00, 'SKU-MEN-002', 'active'),   -- 7
-- Women's Clothing (cat 8)
(8, 'Floral Summer Dress',  'Light chiffon, knee length, floral print',        950.00, 'SKU-WOM-001', 'active'),   -- 8
(8, 'Casual Blazer',        'Single button, lined, office or casual wear',    1800.00, 'SKU-WOM-002', 'active'),   -- 9
-- Kitchen Appliances (cat 9)
(9, 'Blender Pro 600W',     'Stainless steel blades, 1.5L jug, 3 speeds',     2200.00, 'SKU-KIT-001', 'active'),   -- 10
(9, 'Rice Cooker 1.8L',     'Non-stick inner pot, keep-warm function',         1500.00, 'SKU-KIT-002', 'active'),   -- 11
-- Books (cat 4) — one inactive to demo soft-filter
(4, 'Clean Code by R. Martin','Practical guide to writing readable code',       650.00, 'SKU-BOK-001', 'inactive'); -- 12

-- ============================================================
-- 6. PRODUCT_IMAGES  (2 images per product, one marked main)
--    Using Unsplash real photo URLs matched to each product
-- ============================================================
INSERT INTO product_images (product_id, image_url, is_main) VALUES
-- Samsung Galaxy A54
(1,  'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&q=80', TRUE),
(1,  'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&q=80', FALSE),
-- Tecno Spark 20
(2,  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80', TRUE),
(2,  'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=600&q=80', FALSE),
-- iPhone 14
(3,  'https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=600&q=80', TRUE),
(3,  'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=600&q=80', FALSE),
-- HP Pavilion 15
(4,  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80', TRUE),
(4,  'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=600&q=80', FALSE),
-- Lenovo IdeaPad 3
(5,  'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80', TRUE),
(5,  'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&q=80', FALSE),
-- Oxford Shirt
(6,  'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&q=80', TRUE),
(6,  'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?w=600&q=80', FALSE),
-- Chino Trousers
(7,  'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600&q=80', TRUE),
(7,  'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80', FALSE),
-- Floral Dress
(8,  'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80', TRUE),
(8,  'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=80', FALSE),
-- Casual Blazer
(9,  'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600&q=80', TRUE),
(9,  'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=600&q=80', FALSE),
-- Blender
(10, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&q=80', TRUE),
(10, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', FALSE),
-- Rice Cooker
(11, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', TRUE),
(11, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', FALSE),
-- Clean Code book (inactive product still has images)
(12, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600&q=80', TRUE),
(12, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80', FALSE);

-- ============================================================
-- 7. INVENTORY  (one record per product)
-- ============================================================
INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(1,  45,  10),   -- Samsung Galaxy A54
(2,  80,  15),   -- Tecno Spark 20
(3,  12,   5),   -- iPhone 14
(4,  25,   8),   -- HP Pavilion 15
(5,  30,   8),   -- Lenovo IdeaPad 3
(6, 120,  20),   -- Oxford Shirt
(7,  95,  20),   -- Chino Trousers
(8, 110,  20),   -- Floral Dress
(9,  60,  15),   -- Casual Blazer
(10, 40,  10),   -- Blender Pro
(11, 55,  10),   -- Rice Cooker
(12,  0,   5);   -- Clean Code (out of stock / inactive)

-- ============================================================
-- 8. COUPONS_DISCOUNTS  (4 rows)
-- ============================================================
INSERT INTO coupons_discounts
    (coupon_code, discount_type, discount_value, start_date, end_date, min_order_amount, status)
VALUES
('WELCOME10',  'percentage', 10.00, '2024-01-01', '2026-12-31',     0.00, 'active'),   -- 10% off any order
('SAVE500',    'fixed',     500.00, '2024-01-01', '2026-12-31',  5000.00, 'active'),   -- 500 ETB off orders ≥ 5000
('FLASH25',    'percentage', 25.00, '2024-06-01', '2024-06-30',  2000.00, 'expired'),  -- expired flash sale
('FREESHIP',   'fixed',     150.00, '2025-01-01', '2026-12-31',  1000.00, 'active');   -- flat 150 off (simulates free shipping)

-- ============================================================
-- 9. ADDRESSES  (2 addresses per active customer = 10 rows)
-- ============================================================
INSERT INTO addresses (customer_id, street, city, region, postal_code, country, address_type) VALUES
-- Abel (customer 1)
(1, 'Bole Road, Near Edna Mall',      'Addis Ababa', 'Addis Ababa', '1000', 'Ethiopia', 'both'),
(1, 'Kazanchis, Ras Desta Street',    'Addis Ababa', 'Addis Ababa', '1001', 'Ethiopia', 'billing'),
-- Meron (customer 2)
(2, 'Piassa, Churchill Avenue',       'Addis Ababa', 'Addis Ababa', '1002', 'Ethiopia', 'both'),
(2, 'Gerji, Imperial Hotel Area',     'Addis Ababa', 'Addis Ababa', '1003', 'Ethiopia', 'shipping'),
-- Kaleb (customer 3)
(3, 'Megenagna, Ring Road',           'Addis Ababa', 'Addis Ababa', '1004', 'Ethiopia', 'both'),
(3, 'Mexico Square, Main Street',     'Addis Ababa', 'Addis Ababa', '1005', 'Ethiopia', 'billing'),
-- Hana (customer 4)
(4, 'Sarbet, St. Gabriel Area',       'Addis Ababa', 'Addis Ababa', '1006', 'Ethiopia', 'both'),
(4, 'Lebu, Lebu Mebrat Haile',        'Addis Ababa', 'Addis Ababa', '1007', 'Ethiopia', 'shipping'),
-- Dawit (customer 5)
(5, 'Bishoftu, Main Road',            'Bishoftu',    'Oromia',      '1270', 'Ethiopia', 'both'),
(5, 'Bishoftu, Near Lake Hora',       'Bishoftu',    'Oromia',      '1271', 'Ethiopia', 'shipping');

-- ============================================================
-- 10. CARTS  (one active cart per customer + some historical)
-- ============================================================
INSERT INTO carts (customer_id, status) VALUES
(1, 'converted'),  -- cart 1: Abel's old cart (became order)
(1, 'active'),     -- cart 2: Abel's current cart
(2, 'converted'),  -- cart 3: Meron's old cart
(2, 'active'),     -- cart 4: Meron's current cart
(3, 'abandoned'),  -- cart 5: Kaleb abandoned
(3, 'active'),     -- cart 6: Kaleb's current cart
(4, 'active'),     -- cart 7: Hana's cart
(5, 'converted');  -- cart 8: Dawit's old cart (became order)

-- ============================================================
-- 11. CART_ITEMS  (items in the active/abandoned carts)
-- ============================================================
INSERT INTO cart_items (cart_id, product_id, quantity, unit_price) VALUES
-- Cart 2: Abel's active cart (Samsung phone + shirt)
(2, 1,  1, 18500.00),  -- Samsung Galaxy A54
(2, 6,  2,   850.00),  -- Oxford Shirt x2
-- Cart 4: Meron's active cart (dress + blazer)
(4, 8,  1,   950.00),  -- Floral Summer Dress
(4, 9,  1,  1800.00),  -- Casual Blazer
-- Cart 5: Kaleb's abandoned cart (laptop)
(5, 4,  1, 42000.00),  -- HP Pavilion 15
-- Cart 6: Kaleb's current cart (rice cooker + blender)
(6, 10, 1,  2200.00),  -- Blender Pro
(6, 11, 2,  1500.00),  -- Rice Cooker x2
-- Cart 7: Hana's cart (Tecno phone + dress)
(7, 2,  1,  8900.00),  -- Tecno Spark 20
(7, 8,  2,   950.00);  -- Floral Dress x2

-- ============================================================
-- 12. ORDERS  (5 completed orders from converted carts)
-- ============================================================
-- total_amount = sum of order_items subtotals minus coupon discount
INSERT INTO orders (customer_id, address_id, coupon_id, order_date, total_amount, order_status) VALUES
-- Abel: Samsung A54 + Oxford Shirt x2  = 18500 + 1700 = 20200, no coupon
(1, 1, NULL, '2024-11-10 09:15:00', 20200.00, 'delivered'),   -- order 1
-- Abel: Lenovo laptop, SAVE500 applied  = 35000 - 500 = 34500
(1, 1,    2, '2025-01-05 14:30:00', 34500.00, 'delivered'),   -- order 2
-- Meron: Floral Dress + Blender, WELCOME10 applied = (950+2200)=3150 - 10% = 2835
(2, 3,    1, '2025-02-14 10:00:00',  2835.00, 'delivered'),   -- order 3
-- Kaleb: HP Pavilion, no coupon = 42000
(3, 5, NULL, '2025-03-20 16:45:00', 42000.00, 'processing'),  -- order 4
-- Dawit: Rice Cooker x2 + Oxford Shirt = 3000 + 850 = 3850, FREESHIP applied = 3700
(5, 9,    4, '2025-04-01 08:00:00',  3700.00, 'shipped');     -- order 5

-- ============================================================
-- 13. ORDER_ITEMS  (line items for each order above)
-- ============================================================
-- subtotal = quantity * unit_price
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
-- Order 1: Abel
(1, 1, 1, 18500.00, 18500.00),  -- Samsung Galaxy A54
(1, 6, 2,   850.00,  1700.00),  -- Oxford Shirt x2
-- Order 2: Abel (laptop)
(2, 5, 1, 35000.00, 35000.00),  -- Lenovo IdeaPad 3
-- Order 3: Meron
(3, 8, 1,   950.00,   950.00),  -- Floral Dress
(3,10, 1,  2200.00,  2200.00),  -- Blender Pro
-- Order 4: Kaleb
(4, 4, 1, 42000.00, 42000.00),  -- HP Pavilion 15
-- Order 5: Dawit
(5,11, 2,  1500.00,  3000.00),  -- Rice Cooker x2
(5, 6, 1,   850.00,   850.00);  -- Oxford Shirt

-- ============================================================
-- 14. PAYMENTS  (one per delivered/shipped order)
-- ============================================================
INSERT INTO payments (order_id, payment_method, payment_date, amount, payment_status, transaction_reference) VALUES
(1, 'mobile_money',  '2024-11-10 09:20:00', 20200.00, 'completed', 'TXN-MM-00001'),
(2, 'bank_transfer', '2025-01-05 14:35:00', 34500.00, 'completed', 'TXN-BT-00002'),
(3, 'credit_card',   '2025-02-14 10:05:00',  2835.00, 'completed', 'TXN-CC-00003'),
(4, 'cash',          '2025-03-20 17:00:00', 42000.00, 'pending',   NULL),           -- cash on delivery, not yet paid
(5, 'mobile_money',  '2025-04-01 08:10:00',  3700.00, 'completed', 'TXN-MM-00005');

-- ============================================================
-- 15. SHIPPING  (one per order)
-- ============================================================
INSERT INTO shipping (order_id, courier_name, tracking_number, shipping_status, shipped_date, delivered_date) VALUES
(1, 'Ethio Post',    'EP-2024-001', 'delivered',       '2024-11-11 08:00:00', '2024-11-13 14:00:00'),
(2, 'DHL Ethiopia',  'DHL-2025-002','delivered',       '2025-01-06 09:00:00', '2025-01-09 11:30:00'),
(3, 'Ethio Post',    'EP-2025-003', 'delivered',       '2025-02-15 08:00:00', '2025-02-17 16:00:00'),
(4, 'DHL Ethiopia',  'DHL-2025-004','in_transit',      '2025-03-21 10:00:00', NULL),
(5, 'Ethio Post',    'EP-2025-005', 'out_for_delivery','2025-04-02 07:30:00', NULL);

-- ============================================================
-- 16. REVIEWS  (customers review products they ordered)
-- ============================================================
INSERT INTO reviews (customer_id, product_id, rating, comment, review_date) VALUES
-- Abel reviews products from his orders
(1, 1, 5, 'Excellent phone! Battery lasts all day, camera is superb. Highly recommend.', '2024-11-15 10:00:00'),
(1, 6, 4, 'Nice quality shirt. Fits well but runs slightly large. Order one size down.', '2024-11-16 11:30:00'),
(1, 5, 5, 'Great laptop for the price. Fast, light, and the battery life is impressive.', '2025-01-12 09:00:00'),
-- Meron reviews her products
(2, 8, 5, 'Beautiful dress! Material is soft and the print is exactly as shown in photos.', '2025-02-20 14:00:00'),
(2,10, 4, 'Blender works great for smoothies. A bit loud but very powerful for the price.', '2025-02-21 09:00:00'),
-- Dawit reviews his products
(5,11, 3, 'Rice cooker is decent. Does the job but the lid does not seal as tightly as expected.', '2025-04-10 08:00:00'),
(5, 6, 5, 'Perfect shirt. Great fabric and the stitching is solid. Will buy more colors.', '2025-04-11 10:00:00');

-- ============================================================
--  END OF SAMPLE DATA
-- ============================================================
