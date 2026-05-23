// ============================================================
//  controllers/productController.js
//  getAllProducts, getProductById, createProduct,
//  updateProduct, deleteProduct, getCategories
// ============================================================

const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

// ── getAllProducts ─────────────────────────────────────────────
// GET /api/products
// Query params: category_id, search, stock_status, page, limit
const getAllProducts = async (req, res) => {
  try {
    const { category_id, search, stock_status } = req.query;
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.max(1, parseInt(req.query.limit) || 12);
    const offset = (page - 1) * limit;

    let query = `SELECT * FROM active_products_view WHERE 1=1`;
    const params = [];

    if (category_id) {
      query += ` AND (category_name = (SELECT category_name FROM categories WHERE category_id = ?)
                  OR  parent_category = (SELECT category_name FROM categories WHERE category_id = ?))`;
      params.push(category_id, category_id);
    }
    if (search) {
      query += ` AND (product_name LIKE ? OR description LIKE ?)`;
      params.push(`%${search}%`, `%${search}%`);
    }
    if (stock_status) {
      query += ` AND stock_status = ? COLLATE utf8mb4_unicode_ci`;
      params.push(stock_status);
    }

    // Get total count for pagination — use a separate params array
    const countParams = [];
    if (category_id) countParams.push(category_id, category_id);
    if (search)      countParams.push(`%${search}%`, `%${search}%`);
    if (stock_status) countParams.push(stock_status);

    const [countRows] = await db.query(
      `SELECT COUNT(*) AS total FROM active_products_view WHERE 1=1` +
      (category_id ? ` AND (category_name = (SELECT category_name FROM categories WHERE category_id = ?)
                        OR  parent_category = (SELECT category_name FROM categories WHERE category_id = ?))` : '') +
      (search ? ` AND (product_name LIKE ? OR description LIKE ?)` : '') +
      (stock_status ? ` AND stock_status = ? COLLATE utf8mb4_unicode_ci` : ''),
      countParams
    );

    query += ` ORDER BY product_id DESC LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const [products] = await db.query(query, params);

    return sendSuccess(res, {
      products,
      pagination: {
        total:       countRows[0].total,
        page,
        limit,
        total_pages: Math.ceil(countRows[0].total / limit),
      }
    });
  } catch (err) {
    console.error('getAllProducts error:', err);
    return sendError(res);
  }
};

// ── getProductById ─────────────────────────────────────────────
// GET /api/products/:id
const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    // Product details
    const [productRows] = await db.query(
      `SELECT p.*, c.category_name,
              parent.category_name AS parent_category,
              inv.quantity_in_stock, inv.reorder_level
       FROM   products p
       JOIN   categories c       ON p.category_id        = c.category_id
       LEFT JOIN categories parent ON c.parent_category_id = parent.category_id
       JOIN   inventory inv       ON p.product_id         = inv.product_id
       WHERE  p.product_id = ? AND p.deleted_at IS NULL`,
      [id]
    );

    if (productRows.length === 0) {
      return sendError(res, 'Product not found.', 404);
    }

    // All images for this product
    const [images] = await db.query(
      `SELECT image_id, image_url, is_main FROM product_images WHERE product_id = ?`,
      [id]
    );

    // Ratings summary
    const [ratings] = await db.query(
      `SELECT * FROM product_ratings_view WHERE product_id = ?`,
      [id]
    );

    // Recent reviews (latest 5)
    const [reviews] = await db.query(
      `SELECT r.review_id, r.rating, r.comment, r.review_date,
              CONCAT(c.first_name, ' ', c.last_name) AS reviewer_name
       FROM   reviews r
       JOIN   customers c ON r.customer_id = c.customer_id
       WHERE  r.product_id = ?
       ORDER  BY r.review_date DESC
       LIMIT  5`,
      [id]
    );

    return sendSuccess(res, {
      product: productRows[0],
      images,
      ratings:  ratings[0] || null,
      reviews,
    });
  } catch (err) {
    console.error('getProductById error:', err);
    return sendError(res);
  }
};

// ── createProduct  (admin only) ────────────────────────────────
// POST /api/products
// Body: { category_id, product_name, description, price, sku, quantity_in_stock, reorder_level }
const createProduct = async (req, res) => {
  const { category_id, product_name, description, price, sku,
          quantity_in_stock = 0, reorder_level = 10 } = req.body;

  if (!category_id || !product_name || !price || !sku) {
    return sendError(res, 'category_id, product_name, price and sku are required.', 400);
  }

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [result] = await conn.query(
      `INSERT INTO products (category_id, product_name, description, price, sku)
       VALUES (?, ?, ?, ?, ?)`,
      [category_id, product_name, description || null, price, sku]
    );
    const newProductId = result.insertId;

    // Create inventory record
    await conn.query(
      `INSERT INTO inventory (product_id, quantity_in_stock, reorder_level)
       VALUES (?, ?, ?)`,
      [newProductId, quantity_in_stock, reorder_level]
    );

    await conn.commit();
    return sendSuccess(res, { product_id: newProductId }, 'Product created successfully.', 201);
  } catch (err) {
    await conn.rollback();
    if (err.code === 'ER_DUP_ENTRY') {
      return sendError(res, 'A product with that SKU already exists.', 409);
    }
    console.error('createProduct error:', err);
    return sendError(res);
  } finally {
    conn.release();
  }
};

// ── updateProduct  (admin only) ────────────────────────────────
// PUT /api/products/:id
const updateProduct = async (req, res) => {
  const { id } = req.params;
  const { category_id, product_name, description, price, sku, status } = req.body;

  try {
    const [existing] = await db.query(
      `SELECT product_id FROM products WHERE product_id = ? AND deleted_at IS NULL`, [id]
    );
    if (existing.length === 0) return sendError(res, 'Product not found.', 404);

    await db.query(
      `UPDATE products
       SET category_id  = COALESCE(?, category_id),
           product_name = COALESCE(?, product_name),
           description  = COALESCE(?, description),
           price        = COALESCE(?, price),
           sku          = COALESCE(?, sku),
           status       = COALESCE(?, status)
       WHERE product_id = ?`,
      [category_id, product_name, description, price, sku, status, id]
    );

    return sendSuccess(res, null, 'Product updated successfully.');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return sendError(res, 'SKU already in use.', 409);
    console.error('updateProduct error:', err);
    return sendError(res);
  }
};

// ── deleteProduct  (admin only — soft delete) ──────────────────
// DELETE /api/products/:id
const deleteProduct = async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await db.query(
      `UPDATE products SET deleted_at = NOW(), status = 'inactive'
       WHERE product_id = ? AND deleted_at IS NULL`,
      [id]
    );
    if (result.affectedRows === 0) return sendError(res, 'Product not found.', 404);

    return sendSuccess(res, null, 'Product deleted successfully.');
  } catch (err) {
    console.error('deleteProduct error:', err);
    return sendError(res);
  }
};

// ── getCategories ──────────────────────────────────────────────
// GET /api/products/categories
const getCategories = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT c.category_id, c.category_name, c.description,
              c.parent_category_id,
              p.category_name AS parent_name
       FROM   categories c
       LEFT JOIN categories p ON c.parent_category_id = p.category_id
       ORDER  BY COALESCE(c.parent_category_id, c.category_id), c.category_id`
    );
    return sendSuccess(res, rows);
  } catch (err) {
    console.error('getCategories error:', err);
    return sendError(res);
  }
};

module.exports = {
  getAllProducts, getProductById,
  createProduct, updateProduct, deleteProduct,
  getCategories,
};
