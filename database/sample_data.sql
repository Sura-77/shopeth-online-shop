-- ============================================================
--  Online Shop System — Sample Data (sample_data.sql)
--  Covers all 16 tables | 36 products | Realistic e-commerce data
--  Insert order respects FK dependencies
--  Passwords: all demo accounts use password "test"
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
-- All passwords are bcrypt hash of: test
INSERT INTO users (role_id, username, email, password, phone, status) VALUES
-- Admins
(1, 'admin_sara',   'sara@shopAdmin.com',    '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251911000001', 'active'),
(1, 'admin_john',   'john@shopAdmin.com',    '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251911000002', 'active'),
-- Customers
(2, 'abel_t',       'abel@email.com',        '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000001', 'active'),
(2, 'meron_g',      'meron@email.com',       '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000002', 'active'),
(2, 'kaleb_m',      'kaleb@email.com',       '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000003', 'active'),
(2, 'hana_b',       'hana@email.com',        '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000004', 'active'),
(2, 'dawit_f',      'dawit@email.com',       '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000005', 'active'),
(2, 'tigist_w',     'tigist@email.com',      '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a', '+251912000006', 'inactive');

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
-- 5. PRODUCTS  (36 rows across all categories)
-- ============================================================
INSERT INTO products (category_id, product_name, description, price, sku, status) VALUES
-- ── Mobile Phones (cat 5) ────────────────────────────────────
(5, 'Samsung Galaxy A54',   '6.4" AMOLED, 128GB, 5000mAh battery',                    18500.00, 'SKU-MOB-001', 'active'),   -- 1
(5, 'Tecno Spark 20',       '6.56" display, 128GB, 5000mAh, dual SIM',                  8900.00, 'SKU-MOB-002', 'active'),   -- 2
(5, 'iPhone 14',            '6.1" Super Retina, 128GB, iOS 16',                        65000.00, 'SKU-MOB-003', 'active'),   -- 3
(5, 'Samsung Galaxy S23',   '6.1" Dynamic AMOLED, 256GB, 50MP triple camera',          72000.00, 'SKU-MOB-004', 'active'),   -- 4
(5, 'Xiaomi Redmi Note 12', '6.67" AMOLED, 128GB, 50MP camera, 5000mAh, fast charge',  12500.00, 'SKU-MOB-005', 'active'),   -- 5
(5, 'Infinix Hot 30',       '6.78" IPS LCD, 128GB, 50MP AI camera, 5000mAh',            7200.00, 'SKU-MOB-006', 'active'),   -- 6
-- ── Laptops (cat 6) ─────────────────────────────────────────
(6, 'HP Pavilion 15',       'Intel i5, 8GB RAM, 512GB SSD, Win 11',                    42000.00, 'SKU-LAP-001', 'active'),   -- 7
(6, 'Lenovo IdeaPad 3',     'AMD Ryzen 5, 8GB RAM, 256GB SSD',                         35000.00, 'SKU-LAP-002', 'active'),   -- 8
(6, 'Dell Inspiron 15',     'Intel Core i7, 16GB RAM, 512GB SSD, 15.6" FHD, Win 11',   55000.00, 'SKU-LAP-003', 'active'),   -- 9
(6, 'MacBook Air M2',       'Apple M2 chip, 8GB RAM, 256GB SSD, 13.6" Liquid Retina',  98000.00, 'SKU-LAP-004', 'active'),   -- 10
(6, 'Asus VivoBook 15',     'Intel Core i5, 8GB RAM, 512GB SSD, 15.6" FHD display',    38000.00, 'SKU-LAP-005', 'active'),   -- 11
-- ── Men's Clothing (cat 7) ───────────────────────────────────
(7, 'Classic Oxford Shirt', '100% cotton, slim fit, available S-XXL',                     850.00, 'SKU-MEN-001', 'active'),   -- 12
(7, 'Chino Trousers',       'Stretch cotton chino, multiple colors',                      1200.00, 'SKU-MEN-002', 'active'),   -- 13
(7, 'Slim Fit Denim Jeans', 'Stretch denim, slim fit, available in blue and black',       1400.00, 'SKU-MEN-003', 'active'),   -- 14
(7, 'Leather Jacket',       'Genuine leather, biker style, zip closure, sizes S-XXL',    5500.00, 'SKU-MEN-004', 'active'),   -- 15
(7, 'Polo T-Shirt',         '100% cotton pique, short sleeve, embroidered logo',           650.00, 'SKU-MEN-005', 'active'),   -- 16
-- ── Women's Clothing (cat 8) ─────────────────────────────────
(8, 'Floral Summer Dress',  'Light chiffon, knee length, floral print',                    950.00, 'SKU-WOM-001', 'active'),   -- 17
(8, 'Casual Blazer',        'Single button, lined, office or casual wear',                1800.00, 'SKU-WOM-002', 'active'),   -- 18
(8, 'High-Waist Skinny Jeans','Stretch denim, high waist, ankle length, sizes 26-34',    1600.00, 'SKU-WOM-003', 'active'),   -- 19
(8, 'Wrap Midi Dress',      'Satin finish, wrap style, midi length, floral and solid',    1350.00, 'SKU-WOM-004', 'active'),   -- 20
(8, 'Knit Cardigan',        'Soft ribbed knit, open front, long sleeve, sizes XS-XL',    1100.00, 'SKU-WOM-005', 'active'),   -- 21
-- ── Kitchen Appliances (cat 9) ───────────────────────────────
(9, 'Blender Pro 600W',     'Stainless steel blades, 1.5L jug, 3 speeds',                2200.00, 'SKU-KIT-001', 'active'),   -- 22
(9, 'Rice Cooker 1.8L',     'Non-stick inner pot, keep-warm function',                    1500.00, 'SKU-KIT-002', 'active'),   -- 23
(9, 'Stand Mixer 1000W',    '5L stainless steel bowl, 10 speeds, dough hook and whisk',   8500.00, 'SKU-KIT-003', 'active'),   -- 24
(9, 'Air Fryer 5.5L',       'Digital display, 8 presets, 1700W, non-stick basket',        4200.00, 'SKU-KIT-004', 'active'),   -- 25
(9, 'Electric Kettle 1.7L', 'Stainless steel, 2200W, auto shut-off, boil-dry protection', 1200.00, 'SKU-KIT-005', 'active'),   -- 26
-- ── Books & Stationery (cat 4) ───────────────────────────────
(4, 'Clean Code by R. Martin','Practical guide to writing readable code',                   650.00, 'SKU-BOK-001', 'inactive'), -- 27
(4, 'Atomic Habits',        'Practical strategies for building good habits',                750.00, 'SKU-BOK-002', 'active'),   -- 28
(4, 'The Pragmatic Programmer','Classic software engineering guide, 20th anniversary ed.',  850.00, 'SKU-BOK-003', 'active'),   -- 29
-- ── Stationery (cat 10) ──────────────────────────────────────
(10,'Premium Notebook A5',  'Hardcover, 200 pages, dot grid, lay-flat binding',             320.00, 'SKU-STA-001', 'active'),   -- 30
(10,'Gel Pen Set 12-Pack',  'Smooth writing, 0.5mm tip, assorted colors, quick-dry ink',    180.00, 'SKU-STA-002', 'active'),   -- 31
-- ── Electronics accessories (cat 1) ─────────────────────────
(1, 'Wireless Bluetooth Earbuds','ANC, 30hr battery, IPX5 waterproof, USB-C charging',    3500.00, 'SKU-ELC-001', 'active'),   -- 32
(1, 'USB-C Fast Charger 65W','GaN technology, foldable plug, compatible with laptops',      950.00, 'SKU-ELC-002', 'active'),   -- 33
(1, 'Mechanical Keyboard',  'TKL layout, blue switches, RGB backlight, USB-C cable',       4800.00, 'SKU-ELC-003', 'active'),   -- 34
-- ── Home & Kitchen top-level (cat 3) ────────────────────────
(3, 'Ceramic Dinner Set 12-Piece','Microwave safe, white with gold rim, service for 4',   2800.00, 'SKU-HOM-001', 'active'),   -- 35
(3, 'Memory Foam Pillow',   'Ergonomic cervical support, cooling gel layer, washable',     1450.00, 'SKU-HOM-002', 'active');   -- 36

-- ============================================================
-- 6. PRODUCT_IMAGES  (2 images per product, matched to product)
-- ============================================================
INSERT INTO product_images (product_id, image_url, is_main) VALUES
-- 1. Samsung Galaxy A54
(1,  'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&q=80', TRUE),
(1,  'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&q=80', FALSE),
-- 2. Tecno Spark 20
(2,  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80', TRUE),
(2,  'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=600&q=80', FALSE),
-- 3. iPhone 14
(3,  'https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=600&q=80', TRUE),
(3,  'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=600&q=80', FALSE),
-- 4. Samsung Galaxy S23
(4,  'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&q=80', TRUE),
(4,  'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&q=80', FALSE),
-- 5. Xiaomi Redmi Note 12
(5,  'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&q=80', TRUE),
(5,  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80', FALSE),
-- 6. Infinix Hot 30
(6,  'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=600&q=80', TRUE),
(6,  'https://images.unsplash.com/photo-1512054502232-10a0a035d672?w=600&q=80', FALSE),
-- 7. HP Pavilion 15
(7,  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80', TRUE),
(7,  'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=600&q=80', FALSE),
-- 8. Lenovo IdeaPad 3
(8,  'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80', TRUE),
(8,  'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&q=80', FALSE),
-- 9. Dell Inspiron 15
(9,  'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80', TRUE),
(9,  'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=600&q=80', FALSE),
-- 10. MacBook Air M2
(10, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80', TRUE),
(10, 'https://images.unsplash.com/photo-1611186871525-9c4f9b855c3e?w=600&q=80', FALSE),
-- 11. Asus VivoBook 15
(11, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&q=80', TRUE),
(11, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80', FALSE),
-- 12. Classic Oxford Shirt
(12, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&q=80', TRUE),
(12, 'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?w=600&q=80', FALSE),
-- 13. Chino Trousers
(13, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600&q=80', TRUE),
(13, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80', FALSE),
-- 14. Slim Fit Denim Jeans
(14, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80', TRUE),
(14, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600&q=80', FALSE),
-- 15. Leather Jacket
(15, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80', TRUE),
(15, 'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=600&q=80', FALSE),
-- 16. Polo T-Shirt
(16, 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=600&q=80', TRUE),
(16, 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600&q=80', FALSE),
-- 17. Floral Summer Dress
(17, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80', TRUE),
(17, 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=80', FALSE),
-- 18. Casual Blazer
(18, 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600&q=80', TRUE),
(18, 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=600&q=80', FALSE),
-- 19. High-Waist Skinny Jeans
(19, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80', TRUE),
(19, 'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=600&q=80', FALSE),
-- 20. Wrap Midi Dress
(20, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&q=80', TRUE),
(20, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80', FALSE),
-- 21. Knit Cardigan
(21, 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80', TRUE),
(21, 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=80', FALSE),
-- 22. Blender Pro 600W
(22, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&q=80', TRUE),
(22, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', FALSE),
-- 23. Rice Cooker 1.8L
(23, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', TRUE),
(23, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', FALSE),
-- 24. Stand Mixer 1000W
(24, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80', TRUE),
(24, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', FALSE),
-- 25. Air Fryer 5.5L
(25, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', TRUE),
(25, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&q=80', FALSE),
-- 26. Electric Kettle 1.7L
(26, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&q=80', TRUE),
(26, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&q=80', FALSE),
-- 27. Clean Code (inactive)
(27, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600&q=80', TRUE),
(27, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80', FALSE),
-- 28. Atomic Habits
(28, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80', TRUE),
(28, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&q=80', FALSE),
-- 29. The Pragmatic Programmer
(29, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600&q=80', TRUE),
(29, 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600&q=80', FALSE),
-- 30. Premium Notebook A5
(30, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80', TRUE),
(30, 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=600&q=80', FALSE),
-- 31. Gel Pen Set 12-Pack
(31, 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=600&q=80', TRUE),
(31, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80', FALSE),
-- 32. Wireless Bluetooth Earbuds
(32, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80', TRUE),
(32, 'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=600&q=80', FALSE),
-- 33. USB-C Fast Charger 65W
(33, 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=600&q=80', TRUE),
(33, 'https://images.unsplash.com/photo-1601524909162-ae8725290836?w=600&q=80', FALSE),
-- 34. Mechanical Keyboard
(34, 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=600&q=80', TRUE),
(34, 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&q=80', FALSE),
-- 35. Ceramic Dinner Set
(35, 'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?w=600&q=80', TRUE),
(35, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', FALSE),
-- 36. Memory Foam Pillow
(36, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80', TRUE),
(36, 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80', FALSE);

-- ============================================================
-- 7. INVENTORY  (one record per product — all 36)
-- ============================================================
INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(1,  45,  10),   -- Samsung Galaxy A54
(2,  80,  15),   -- Tecno Spark 20
(3,  12,   5),   -- iPhone 14
(4,  35,   8),   -- Samsung Galaxy S23
(5,  60,  12),   -- Xiaomi Redmi Note 12
(6,  90,  15),   -- Infinix Hot 30
(7,  25,   8),   -- HP Pavilion 15
(8,  30,   8),   -- Lenovo IdeaPad 3
(9,  20,   5),   -- Dell Inspiron 15
(10,  8,   3),   -- MacBook Air M2
(11, 28,   8),   -- Asus VivoBook 15
(12,120,  20),   -- Classic Oxford Shirt
(13, 95,  20),   -- Chino Trousers
(14,100,  20),   -- Slim Fit Denim Jeans
(15, 25,   8),   -- Leather Jacket
(16,150,  25),   -- Polo T-Shirt
(17,110,  20),   -- Floral Summer Dress
(18, 60,  15),   -- Casual Blazer
(19, 85,  20),   -- High-Waist Skinny Jeans
(20, 70,  15),   -- Wrap Midi Dress
(21, 55,  12),   -- Knit Cardigan
(22, 40,  10),   -- Blender Pro 600W
(23, 55,  10),   -- Rice Cooker 1.8L
(24, 18,   5),   -- Stand Mixer 1000W
(25, 32,   8),   -- Air Fryer 5.5L
(26, 65,  12),   -- Electric Kettle 1.7L
(27,  0,   5),   -- Clean Code (out of stock / inactive)
(28, 80,  15),   -- Atomic Habits
(29, 45,  10),   -- The Pragmatic Programmer
(30,200,  30),   -- Premium Notebook A5
(31,300,  50),   -- Gel Pen Set 12-Pack
(32, 50,  10),   -- Wireless Bluetooth Earbuds
(33,120,  20),   -- USB-C Fast Charger 65W
(34, 22,   6),   -- Mechanical Keyboard
(35, 40,  10),   -- Ceramic Dinner Set
(36, 60,  12);   -- Memory Foam Pillow

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
(2,  1, 1, 18500.00),  -- Samsung Galaxy A54
(2, 12, 2,   850.00),  -- Oxford Shirt x2
-- Cart 4: Meron's active cart (dress + blazer)
(4, 17, 1,   950.00),  -- Floral Summer Dress
(4, 18, 1,  1800.00),  -- Casual Blazer
-- Cart 5: Kaleb's abandoned cart (laptop)
(5,  7, 1, 42000.00),  -- HP Pavilion 15
-- Cart 6: Kaleb's current cart (rice cooker + blender)
(6, 22, 1,  2200.00),  -- Blender Pro
(6, 23, 2,  1500.00),  -- Rice Cooker x2
-- Cart 7: Hana's cart (Tecno phone + dress)
(7,  2, 1,  8900.00),  -- Tecno Spark 20
(7, 17, 2,   950.00);  -- Floral Dress x2

-- ============================================================
-- 12. ORDERS  (5 completed orders from converted carts)
-- ============================================================
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
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
-- Order 1: Abel
(1,  1, 1, 18500.00, 18500.00),  -- Samsung Galaxy A54
(1, 12, 2,   850.00,  1700.00),  -- Oxford Shirt x2
-- Order 2: Abel (laptop)
(2,  8, 1, 35000.00, 35000.00),  -- Lenovo IdeaPad 3
-- Order 3: Meron
(3, 17, 1,   950.00,   950.00),  -- Floral Dress
(3, 22, 1,  2200.00,  2200.00),  -- Blender Pro
-- Order 4: Kaleb
(4,  7, 1, 42000.00, 42000.00),  -- HP Pavilion 15
-- Order 5: Dawit
(5, 23, 2,  1500.00,  3000.00),  -- Rice Cooker x2
(5, 12, 1,   850.00,   850.00);  -- Oxford Shirt

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
(1,  1, 5, 'Excellent phone! Battery lasts all day, camera is superb. Highly recommend.', '2024-11-15 10:00:00'),
(1, 12, 4, 'Nice quality shirt. Fits well but runs slightly large. Order one size down.', '2024-11-16 11:30:00'),
(1,  8, 5, 'Great laptop for the price. Fast, light, and the battery life is impressive.', '2025-01-12 09:00:00'),
-- Meron reviews her products
(2, 17, 5, 'Beautiful dress! Material is soft and the print is exactly as shown in photos.', '2025-02-20 14:00:00'),
(2, 22, 4, 'Blender works great for smoothies. A bit loud but very powerful for the price.', '2025-02-21 09:00:00'),
-- Dawit reviews his products
(5, 23, 3, 'Rice cooker is decent. Does the job but the lid does not seal as tightly as expected.', '2025-04-10 08:00:00'),
(5, 12, 5, 'Perfect shirt. Great fabric and the stitching is solid. Will buy more colors.', '2025-04-11 10:00:00');

-- ============================================================
--  END OF SAMPLE DATA
-- ============================================================
