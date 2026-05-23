// ============================================================
//  controllers/addressController.js
//  getAddresses, addAddress, deleteAddress
// ============================================================

const db = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

// ── helper ────────────────────────────────────────────────────
const getCustomerId = async (userId) => {
  const [rows] = await db.query(
    'SELECT customer_id FROM customers WHERE user_id = ?', [userId]
  );
  return rows[0]?.customer_id || null;
};

// ── getAddresses ──────────────────────────────────────────────
// GET /api/addresses
// Returns all saved addresses for the logged-in customer.
const getAddresses = async (req, res) => {
  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    const [rows] = await db.query(
      `SELECT address_id, street, city, region, postal_code, country, address_type
       FROM   addresses
       WHERE  customer_id = ?
       ORDER  BY address_id ASC`,
      [customerId]
    );

    return sendSuccess(res, rows);
  } catch (err) {
    console.error('getAddresses error:', err);
    return sendError(res);
  }
};

// ── addAddress ────────────────────────────────────────────────
// POST /api/addresses
// Body: { street, city, region, postal_code, country, address_type }
const addAddress = async (req, res) => {
  const { street, city, region = null, postal_code = null,
          country, address_type = 'both' } = req.body;

  if (!street || !city || !country) {
    return sendError(res, 'street, city and country are required.', 400);
  }

  const validTypes = ['billing', 'shipping', 'both'];
  if (!validTypes.includes(address_type)) {
    return sendError(res, "address_type must be 'billing', 'shipping', or 'both'.", 400);
  }

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    const [result] = await db.query(
      `INSERT INTO addresses (customer_id, street, city, region, postal_code, country, address_type)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [customerId, street, city, region, postal_code, country, address_type]
    );

    return sendSuccess(res, { address_id: result.insertId }, 'Address added.', 201);
  } catch (err) {
    console.error('addAddress error:', err);
    return sendError(res);
  }
};

// ── deleteAddress ─────────────────────────────────────────────
// DELETE /api/addresses/:id
const deleteAddress = async (req, res) => {
  const { id } = req.params;

  try {
    const customerId = await getCustomerId(req.user.user_id);
    if (!customerId) return sendError(res, 'Customer profile not found.', 404);

    const [result] = await db.query(
      'DELETE FROM addresses WHERE address_id = ? AND customer_id = ?',
      [id, customerId]
    );

    if (result.affectedRows === 0) return sendError(res, 'Address not found.', 404);

    return sendSuccess(res, null, 'Address deleted.');
  } catch (err) {
    console.error('deleteAddress error:', err);
    return sendError(res);
  }
};

module.exports = { getAddresses, addAddress, deleteAddress };
