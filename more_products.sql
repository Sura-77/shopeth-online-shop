-- ============================================================
--  more_products.sql
--  24 additional products (2-3 per category) with accurate
--  Unsplash image URLs matched precisely to each product.
--  Run AFTER sample_data.sql.
--  Products start at ID 13 (existing 12 + 1).
-- ============================================================

USE online_shop_db;

-- ============================================================
-- PRODUCTS
-- ============================================================
INSERT INTO products (category_id, product_name, description, price, sku, status) VALUES

-- ── Mobile Phones (cat 5) ────────────────────────────────────
(5, 'Samsung Galaxy S23',
    '6.1" Dynamic AMOLED, 256GB, 50MP triple camera, 3900mAh',
    72000.00, 'SKU-MOB-004', 'active'),                                        -- 13

(5, 'Xiaomi Redmi Note 12',
    '6.67" AMOLED, 128GB, 50MP camera, 5000mAh, fast charge',
    12500.00, 'SKU-MOB-005', 'active'),                                        -- 14

(5, 'Infinix Hot 30',
    '6.78" IPS LCD, 128GB, 50MP AI camera, 5000mAh',
     7200.00, 'SKU-MOB-006', 'active'),                                        -- 15

-- ── Laptops (cat 6) ─────────────────────────────────────────
(6, 'Dell Inspiron 15',
    'Intel Core i7, 16GB RAM, 512GB SSD, 15.6" FHD, Win 11',
    55000.00, 'SKU-LAP-003', 'active'),                                        -- 16

(6, 'MacBook Air M2',
    'Apple M2 chip, 8GB RAM, 256GB SSD, 13.6" Liquid Retina',
    98000.00, 'SKU-LAP-004', 'active'),                                        -- 17

(6, 'Asus VivoBook 15',
    'Intel Core i5, 8GB RAM, 512GB SSD, 15.6" FHD display',
    38000.00, 'SKU-LAP-005', 'active'),                                        -- 18

-- ── Men's Clothing (cat 7) ───────────────────────────────────
(7, 'Slim Fit Denim Jeans',
    'Stretch denim, slim fit, available in blue and black, sizes 28-38',
     1400.00, 'SKU-MEN-003', 'active'),                                        -- 19

(7, 'Leather Jacket',
    'Genuine leather, biker style, zip closure, sizes S-XXL',
     5500.00, 'SKU-MEN-004', 'active'),                                        -- 20

(7, 'Polo T-Shirt',
    '100% cotton pique, short sleeve, embroidered logo, sizes S-XXL',
      650.00, 'SKU-MEN-005', 'active'),                                        -- 21

-- ── Women's Clothing (cat 8) ─────────────────────────────────
(8, 'High-Waist Skinny Jeans',
    'Stretch denim, high waist, ankle length, sizes 26-34',
     1600.00, 'SKU-WOM-003', 'active'),                                        -- 22

(8, 'Wrap Midi Dress',
    'Satin finish, wrap style, midi length, floral and solid options',
     1350.00, 'SKU-WOM-004', 'active'),                                        -- 23

(8, 'Knit Cardigan',
    'Soft ribbed knit, open front, long sleeve, sizes XS-XL',
     1100.00, 'SKU-WOM-005', 'active'),                                        -- 24

-- ── Kitchen Appliances (cat 9) ───────────────────────────────
(9, 'Stand Mixer 1000W',
    '5L stainless steel bowl, 10 speeds, dough hook and whisk included',
     8500.00, 'SKU-KIT-003', 'active'),                                        -- 25

(9, 'Air Fryer 5.5L',
    'Digital display, 8 presets, 1700W, non-stick basket, rapid air tech',
     4200.00, 'SKU-KIT-004', 'active'),                                        -- 26

(9, 'Electric Kettle 1.7L',
    'Stainless steel, 2200W, auto shut-off, boil-dry protection',
     1200.00, 'SKU-KIT-005', 'active'),                                        -- 27

-- ── Books & Stationery (cat 4) ───────────────────────────────
(4, 'Atomic Habits by James Clear',
    'Practical strategies for building good habits and breaking bad ones',
      750.00, 'SKU-BOK-002', 'active'),                                        -- 28

(4, 'The Pragmatic Programmer',
    'Classic software engineering guide by Hunt and Thomas, 20th anniversary ed.',
      850.00, 'SKU-BOK-003', 'active'),                                        -- 29

-- ── Stationery (cat 10) ──────────────────────────────────────
(10, 'Premium Notebook A5',
     'Hardcover, 200 pages, dot grid, lay-flat binding',
       320.00, 'SKU-STA-001', 'active'),                                       -- 30

(10, 'Gel Pen Set 12-Pack',
     'Smooth writing, 0.5mm tip, assorted colors, quick-dry ink',
       180.00, 'SKU-STA-002', 'active'),                                       -- 31

-- ── Electronics accessories (cat 1 — top level) ─────────────
(1, 'Wireless Bluetooth Earbuds',
    'Active noise cancellation, 30hr battery, IPX5 waterproof, USB-C charging',
     3500.00, 'SKU-ELC-001', 'active'),                                        -- 32

(1, 'USB-C Fast Charger 65W',
    'GaN technology, foldable plug, compatible with laptops and phones',
      950.00, 'SKU-ELC-002', 'active'),                                        -- 33

(1, 'Mechanical Keyboard',
    'TKL layout, blue switches, RGB backlight, USB-C detachable cable',
     4800.00, 'SKU-ELC-003', 'active'),                                        -- 34

-- ── Home & Kitchen top-level (cat 3) ────────────────────────
(3, 'Ceramic Dinner Set 12-Piece',
    'Microwave and dishwasher safe, white with gold rim, service for 4',
     2800.00, 'SKU-HOM-001', 'active'),                                        -- 35

(3, 'Memory Foam Pillow',
    'Ergonomic cervical support, cooling gel layer, washable cover',
     1450.00, 'SKU-HOM-002', 'active');                                        -- 36

-- ============================================================
-- INVENTORY  (one record per new product)
-- ============================================================
INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(13,  35,  8),   -- Samsung Galaxy S23
(14,  60, 12),   -- Xiaomi Redmi Note 12
(15,  90, 15),   -- Infinix Hot 30
(16,  20,  5),   -- Dell Inspiron 15
(17,   8,  3),   -- MacBook Air M2
(18,  28,  8),   -- Asus VivoBook 15
(19, 100, 20),   -- Slim Fit Denim Jeans
(20,  25,  8),   -- Leather Jacket
(21, 150, 25),   -- Polo T-Shirt
(22,  85, 20),   -- High-Waist Skinny Jeans
(23,  70, 15),   -- Wrap Midi Dress
(24,  55, 12),   -- Knit Cardigan
(25,  18,  5),   -- Stand Mixer
(26,  32,  8),   -- Air Fryer
(27,  65, 12),   -- Electric Kettle
(28,  80, 15),   -- Atomic Habits
(29,  45, 10),   -- Pragmatic Programmer
(30, 200, 30),   -- Premium Notebook
(31, 300, 50),   -- Gel Pen Set
(32,  50, 10),   -- Wireless Earbuds
(33, 120, 20),   -- USB-C Charger
(34,  22,  6),   -- Mechanical Keyboard
(35,  40, 10),   -- Ceramic Dinner Set
(36,  60, 12);   -- Memory Foam Pillow

-- ============================================================
-- PRODUCT_IMAGES  (2 per product, carefully matched)
-- ============================================================
INSERT INTO product_images (product_id, image_url, is_main) VALUES

-- Samsung Galaxy S23 — Samsung flagship phone flat-lay
(13, 'https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=600&q=80', TRUE),
(13, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&q=80', FALSE),

-- Xiaomi Redmi Note 12 — Android smartphone on desk
(14, 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=600&q=80', TRUE),
(14, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80', FALSE),

-- Infinix Hot 30 — budget Android phone
(15, 'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=600&q=80', TRUE),
(15, 'https://images.unsplash.com/photo-1512054502232-10a0a035d672?w=600&q=80', FALSE),

-- Dell Inspiron 15 — laptop open on desk
(16, 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80', TRUE),
(16, 'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=600&q=80', FALSE),

-- MacBook Air M2 — silver MacBook on clean desk
(17, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80', TRUE),
(17, 'https://images.unsplash.com/photo-1611186871525-9c4f9b855c3e?w=600&q=80', FALSE),

-- Asus VivoBook 15 — laptop keyboard close-up
(18, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&q=80', TRUE),
(18, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80', FALSE),

-- Slim Fit Denim Jeans — folded blue jeans
(19, 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80', TRUE),
(19, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600&q=80', FALSE),

-- Leather Jacket — black leather jacket on hanger
(20, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80', TRUE),
(20, 'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=600&q=80', FALSE),

-- Polo T-Shirt — polo shirt flat lay
(21, 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=600&q=80', TRUE),
(21, 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600&q=80', FALSE),

-- High-Waist Skinny Jeans — women's jeans
(22, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80', TRUE),
(22, 'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=600&q=80', FALSE),

-- Wrap Midi Dress — elegant midi dress
(23, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&q=80', TRUE),
(23, 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80', FALSE),

-- Knit Cardigan — cozy knit cardigan
(24, 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80', TRUE),
(24, 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=80', FALSE),

-- Stand Mixer — KitchenAid style stand mixer
(25, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80', TRUE),
(25, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', FALSE),

-- Air Fryer — digital air fryer on counter
(26, 'https://images.unsplash.com/photo-1648146956409-a5e7e5e5e5e5?w=600&q=80', TRUE),
(26, 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&q=80', FALSE),

-- Electric Kettle — stainless steel kettle
(27, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&q=80', TRUE),
(27, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&q=80', FALSE),

-- Atomic Habits book — book on table
(28, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80', TRUE),
(28, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&q=80', FALSE),

-- The Pragmatic Programmer — programming book
(29, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600&q=80', TRUE),
(29, 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600&q=80', FALSE),

-- Premium Notebook A5 — dot grid notebook open
(30, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80', TRUE),
(30, 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=600&q=80', FALSE),

-- Gel Pen Set — colorful pens arranged
(31, 'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=600&q=80', TRUE),
(31, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&q=80', FALSE),

-- Wireless Earbuds — TWS earbuds in charging case
(32, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80', TRUE),
(32, 'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=600&q=80', FALSE),

-- USB-C Fast Charger — compact charger with cable
(33, 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=600&q=80', TRUE),
(33, 'https://images.unsplash.com/photo-1601524909162-ae8725290836?w=600&q=80', FALSE),

-- Mechanical Keyboard — RGB mechanical keyboard
(34, 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=600&q=80', TRUE),
(34, 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&q=80', FALSE),

-- Ceramic Dinner Set — white ceramic plates and bowls
(35, 'https://images.unsplash.com/photo-1603199506016-b9a594b593c0?w=600&q=80', TRUE),
(35, 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80', FALSE),

-- Memory Foam Pillow — white pillow on bed
(36, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80', TRUE),
(36, 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80', FALSE);

-- ============================================================
--  END OF ADDITIONAL PRODUCTS
--  To apply: run this file in MySQL Workbench after sample_data.sql
-- ============================================================
