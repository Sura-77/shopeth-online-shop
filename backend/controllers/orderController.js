// ============================================================
//  controllers/orderController.js
//  createOrder, getMyOrders, getOrderById,
//  getAllOrders (admin), updateOrderStatus (admin)
// ============================================================

const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getCustomerId = async (userId) => {
  const [rows] = await db.query(
    'SELECT customer_id FROM customers WHERE user_id = ?', [userId]
  );
  return rows[0]?.customer_id || null;
};

// ── createOrder ───────────────────────────────────────────────
// POST /api/orders/create
// Body: { cart_id, address_id, coupon_code (optional) }
// Calls the PlaceOrder() stored procedure
const createOrder = async (req, res) => {
  const { cart_id, address_id, coupon_code = null } = req.body;

  if (!cart_id || !address_id) {
    return sendError(res, 'cart_id and address_id are required.', 400);
  }

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    // Call stored procedure
    await db.query(
      'CALL PlaceOrder(?, ?, ?, ?, @order_id, @msg)',
      [customerId, cart_id, address_id, coupon_code]
    );
    const [[result]] = await db.query('SELECT @order_id AS order_id, @msg AS message');

    if (result.message.startsWith('ERROR:')) {
      return sendError(res, result.message.replace('ERROR: ', ''), 400);
    }

    return sendSuccess(
      res,
      { order_id: result.order_id },
      result.message,
      201
    );
  } catch (err) {
    console.error('createOrder error:', err);
    return sendError(res);
  }
};

// ── getMyOrders ───────────────────────────────────────────────
// GET /api/orders
// Returns the logged-in customer's order history
const getMyOrders = async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    const [orders] = await db.query(
      `SELECT * FROM order_summary_view WHERE customer_id = ? ORDER BY order_date DESC`,
      [customerId]
    );

    return sendSuccess(res, orders);
  } catch (err) {
    console.error('getMyOrders error:', err);
    return sendError(res);
  }
};

// ── getOrderById ──────────────────────────────────────────────
// GET /api/orders/:id
// Customer sees their own order; admin sees any order
const getOrderById = async (req, res) => {
  const { id } = req.params;

  try {
    // Check ownership unless admin
    if (req.user.role_name !== 'admin') {
      const customerId = await getCustomerId(req.user.user_id);
      const [ownerCheck] = await db.query(
        'SELECT order_id FROM orders WHERE order_id = ? AND customer_id = ?',
        [id, customerId]
      );
      if (ownerCheck.length === 0) return sendError(res, 'Order not found.', 404);
    }

    // Call GetOrderSummary() procedure — returns 4 result sets
    const results = await db.query('CALL GetOrderSummary(?)', [id]);
    // mysql2 returns each result set as an element in the outer array
    // Guard against missing result sets (e.g. order has no payment/shipping yet)
    const resultSets = Array.isArray(results[0]) ? results[0] : [];
    const header   = resultSets[0] || [];
    const items    = resultSets[1] || [];
    const payment  = resultSets[2] || [];
    const shipping = resultSets[3] || [];

    if (!header || header.length === 0) return sendError(res, 'Order not found.', 404);

    return sendSuccess(res, {
      order:    header[0],
      items:    items     || [],
      payment:  payment?.[0]  || null,
      shipping: shipping?.[0] || null,
    });
  } catch (err) {
    console.error('getOrderById error:', err);
    return sendError(res);
  }
};

// ── getAllOrders  (admin only) ─────────────────────────────────
// GET /api/orders/admin/all
// Query params: status, page, limit
const getAllOrders = async (req, res) => {
  try {
    const { status } = req.query;
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.max(1, parseInt(req.query.limit) || 20);
    const offset = (page - 1) * limit;

    let query  = `SELECT * FROM order_summary_view WHERE 1=1`;
    let countQ = `SELECT COUNT(DISTINCT order_id) AS total FROM order_summary_view WHERE 1=1`;
    const params = [];

    if (status) {
      query  += ` AND order_status = ?`;
      countQ += ` AND order_status = ?`;
      params.push(status);
    }

    const [countRows] = await db.query(countQ, params);
    query += ` ORDER BY order_date DESC LIMIT ? OFFSET ?`;
    const [orders] = await db.query(query, [...params, limit, offset]);

    return sendSuccess(res, {
      orders,
      pagination: {
        total:       countRows[0].total,
        page,
        limit,
        total_pages: Math.ceil(countRows[0].total / limit),
      }
    });
  } catch (err) {
    console.error('getAllOrders error:', err);
    return sendError(res);
  }
};

// ── updateOrderStatus  (admin only) ───────────────────────────
// PUT /api/orders/admin/:id/status
// Body: { order_status }
const updateOrderStatus = async (req, res) => {
  const { id }           = req.params;
  const { order_status } = req.body;

  const validStatuses = ['pending','confirmed','processing','shipped','delivered','cancelled','refunded'];
  if (!order_status || !validStatuses.includes(order_status)) {
    return sendError(res, `order_status must be one of: ${validStatuses.join(', ')}`, 400);
  }

  try {
    const [result] = await db.query(
      'UPDATE orders SET order_status = ? WHERE order_id = ?',
      [order_status, id]
    );
    if (result.affectedRows === 0) return sendError(res, 'Order not found.', 404);

    return sendSuccess(res, null, `Order status updated to "${order_status}".`);
  } catch (err) {
    console.error('updateOrderStatus error:', err);
    return sendError(res);
  }
};

module.exports = { createOrder, getMyOrders, getOrderById, getAllOrders, updateOrderStatus };
