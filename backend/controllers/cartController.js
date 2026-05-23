// ============================================================
//  controllers/cartController.js
//  getCart, addToCart, updateCartItem, removeFromCart, clearCart
// ============================================================

const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

// ── helper: get customer_id from logged-in user ───────────────
const getCustomerId = async (userId) => {
  const [rows] = await db.query(
    'SELECT customer_id FROM customers WHERE user_id = ?', [userId]
  );
  return rows[0]?.customer_id || null;
};

// ── getCart ───────────────────────────────────────────────────
// GET /api/cart
// Returns the active cart with all items and a running total.
const getCart = async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    // Find active cart
    const [cartRows] = await db.query(
      `SELECT cart_id, created_at FROM carts
       WHERE customer_id = ? AND status = 'active' LIMIT 1`,
      [customerId]
    );

    if (cartRows.length === 0) {
      return sendSuccess(res, { cart: null, items: [], total: 0 }, 'Cart is empty.');
    }

    const cartId = cartRows[0].cart_id;

    // Get cart items with product details
    const [items] = await db.query(
      `SELECT ci.cart_item_id, ci.product_id, ci.quantity, ci.unit_price,
              (ci.quantity * ci.unit_price) AS subtotal,
              p.product_name, p.sku, p.status AS product_status,
              img.image_url AS main_image,
              inv.quantity_in_stock AS stock_available
       FROM   cart_items ci
       JOIN   products       p   ON ci.product_id = p.product_id
       LEFT JOIN product_images img ON p.product_id  = img.product_id AND img.is_main = TRUE
       JOIN   inventory      inv ON ci.product_id = inv.product_id
       WHERE  ci.cart_id = ?`,
      [cartId]
    );

    const total = items.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);

    return sendSuccess(res, {
      cart:  cartRows[0],
      items,
      total: parseFloat(total.toFixed(2)),
    });
  } catch (err) {
    console.error('getCart error:', err);
    return sendError(res);
  }
};

// ── addToCart ─────────────────────────────────────────────────
// POST /api/cart/add
// Body: { product_id, quantity }
// Delegates to the PlaceOrder-companion stored procedure AddToCart()
const addToCart = async (req, res) => {
  const { product_id, quantity = 1 } = req.body;

  if (!product_id) return sendError(res, 'product_id is required.', 400);
  if (quantity < 1) return sendError(res, 'Quantity must be at least 1.', 400);

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    // Call the stored procedure
    await db.query('CALL AddToCart(?, ?, ?, @msg)', [customerId, product_id, quantity]);
    const [[msgRow]] = await db.query('SELECT @msg AS message');
    const message = msgRow.message;

    if (message.startsWith('ERROR:')) {
      return sendError(res, message.replace('ERROR: ', ''), 400);
    }

    return sendSuccess(res, null, message);
  } catch (err) {
    console.error('addToCart error:', err);
    return sendError(res);
  }
};

// ── updateCartItem ────────────────────────────────────────────
// PUT /api/cart/update
// Body: { cart_item_id, quantity }
const updateCartItem = async (req, res) => {
  const { cart_item_id, quantity } = req.body;

  if (!cart_item_id || !quantity) return sendError(res, 'cart_item_id and quantity are required.', 400);
  if (quantity < 1)               return sendError(res, 'Quantity must be at least 1.', 400);

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    // Verify this cart item belongs to this customer's active cart
    const [ownerCheck] = await db.query(
      `SELECT ci.cart_item_id, inv.quantity_in_stock
       FROM   cart_items ci
       JOIN   carts       c   ON ci.cart_id     = c.cart_id
       JOIN   inventory   inv ON ci.product_id  = inv.product_id
       WHERE  ci.cart_item_id = ?
         AND  c.customer_id   = ?
         AND  c.status        = 'active'`,
      [cart_item_id, customerId]
    );

    if (ownerCheck.length === 0) {
      return sendError(res, 'Cart item not found.', 404);
    }

    if (quantity > ownerCheck[0].quantity_in_stock) {
      return sendError(res, `Only ${ownerCheck[0].quantity_in_stock} unit(s) available.`, 400);
    }

    await db.query(
      'UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?',
      [quantity, cart_item_id]
    );

    return sendSuccess(res, null, 'Cart updated.');
  } catch (err) {
    console.error('updateCartItem error:', err);
    return sendError(res);
  }
};

// ── removeFromCart ────────────────────────────────────────────
// DELETE /api/cart/remove/:cart_item_id
const removeFromCart = async (req, res) => {
  const { cart_item_id } = req.params;

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    const [ownerCheck] = await db.query(
      `SELECT ci.cart_item_id FROM cart_items ci
       JOIN   carts c ON ci.cart_id = c.cart_id
       WHERE  ci.cart_item_id = ? AND c.customer_id = ? AND c.status = 'active'`,
      [cart_item_id, customerId]
    );

    if (ownerCheck.length === 0) return sendError(res, 'Cart item not found.', 404);

    await db.query('DELETE FROM cart_items WHERE cart_item_id = ?', [cart_item_id]);
    return sendSuccess(res, null, 'Item removed from cart.');
  } catch (err) {
    console.error('removeFromCart error:', err);
    return sendError(res);
  }
};

// ── clearCart ─────────────────────────────────────────────────
// DELETE /api/cart/clear
// Removes all items from the active cart.
const clearCart = async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.user_id);

    const [cartRows] = await db.query(
      `SELECT cart_id FROM carts WHERE customer_id = ? AND status = 'active' LIMIT 1`,
      [customerId]
    );

    if (cartRows.length === 0) return sendSuccess(res, null, 'Cart is already empty.');

    await db.query('DELETE FROM cart_items WHERE cart_id = ?', [cartRows[0].cart_id]);
    return sendSuccess(res, null, 'Cart cleared.');
  } catch (err) {
    console.error('clearCart error:', err);
    return sendError(res);
  }
};

module.exports = { getCart, addToCart, updateCartItem, removeFromCart, clearCart };
