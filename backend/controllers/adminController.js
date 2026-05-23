// ============================================================
//  controllers/adminController.js
//  getDashboardStats, getLowStock, updateStock,
//  getAllUsers, updateUserStatus
// ============================================================

const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

// ── getDashboardStats ─────────────────────────────────────────
// GET /api/admin/dashboard
// Returns summary numbers for the admin dashboard
const getDashboardStats = async (req, res) => {
  try {
    const [[productStats]] = await db.query(
      `SELECT COUNT(*) AS total_products,
              SUM(status = 'active') AS active_products
       FROM products WHERE deleted_at IS NULL`
    );

    const [[orderStats]] = await db.query(
      `SELECT COUNT(*)                             AS total_orders,
              SUM(order_status = 'pending')        AS pending_orders,
              SUM(order_status = 'processing')     AS processing_orders,
              SUM(order_status = 'delivered')      AS delivered_orders,
              COALESCE(SUM(total_amount), 0)       AS total_revenue
       FROM orders`
    );

    const [[customerStats]] = await db.query(
      `SELECT COUNT(*) AS total_customers FROM customers`
    );

    const [[lowStockCount]] = await db.query(
      `SELECT COUNT(*) AS low_stock_count FROM low_stock_view`
    );

    return sendSuccess(res, {
      products:  productStats,
      orders:    orderStats,
      customers: customerStats,
      inventory: lowStockCount,
    });
  } catch (err) {
    console.error('getDashboardStats error:', err);
    return sendError(res);
  }
};

// ── getLowStock ───────────────────────────────────────────────
// GET /api/admin/inventory/low-stock
const getLowStock = async (req, res) => {
  try {
    // Query the view directly — no need to call the procedure separately
    const [rows] = await db.query('SELECT * FROM low_stock_view');
    return sendSuccess(res, rows);
  } catch (err) {
    console.error('getLowStock error:', err);
    return sendError(res);
  }
};

// ── updateStock ───────────────────────────────────────────────
// PUT /api/admin/inventory/:product_id
// Body: { quantity }
const updateStock = async (req, res) => {
  const { product_id } = req.params;
  const { quantity }   = req.body;

  if (quantity === undefined || quantity === null) {
    return sendError(res, 'quantity is required.', 400);
  }
  const parsedQty = Number(quantity);
  if (!Number.isFinite(parsedQty) || parsedQty < 0) {
    return sendError(res, 'quantity must be a non-negative number.', 400);
  }

  try {
    await db.query('CALL UpdateProductStock(?, ?, @msg)', [product_id, quantity]);
    const [[result]] = await db.query('SELECT @msg AS message');

    if (result.message.startsWith('ERROR:')) {
      return sendError(res, result.message.replace('ERROR: ', ''), 400);
    }

    return sendSuccess(res, null, result.message);
  } catch (err) {
    console.error('updateStock error:', err);
    return sendError(res);
  }
};

// ── getAllUsers ───────────────────────────────────────────────
// GET /api/admin/users
const getAllUsers = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT u.user_id, u.username, u.email, u.phone, u.status, u.created_at,
              r.role_name,
              c.first_name, c.last_name
       FROM   users u
       JOIN   roles r ON u.role_id  = r.role_id
       LEFT JOIN customers c ON u.user_id = c.user_id
       WHERE  u.deleted_at IS NULL
       ORDER  BY u.created_at DESC`
    );
    return sendSuccess(res, rows);
  } catch (err) {
    console.error('getAllUsers error:', err);
    return sendError(res);
  }
};

// ── updateUserStatus ──────────────────────────────────────────
// PUT /api/admin/users/:user_id/status
// Body: { status }  — 'active' | 'inactive' | 'banned'
const updateUserStatus = async (req, res) => {
  const { user_id } = req.params;
  const { status }  = req.body;

  if (!['active', 'inactive', 'banned'].includes(status)) {
    return sendError(res, "status must be 'active', 'inactive', or 'banned'.", 400);
  }

  try {
    const [result] = await db.query(
      'UPDATE users SET status = ? WHERE user_id = ? AND deleted_at IS NULL',
      [status, user_id]
    );
    if (result.affectedRows === 0) return sendError(res, 'User not found.', 404);

    return sendSuccess(res, null, `User status updated to "${status}".`);
  } catch (err) {
    console.error('updateUserStatus error:', err);
    return sendError(res);
  }
};

module.exports = { getDashboardStats, getLowStock, updateStock, getAllUsers, updateUserStatus };
