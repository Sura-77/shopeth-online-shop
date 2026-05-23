// ============================================================
//  controllers/authController.js
//  register, login, getMe
// ============================================================

const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');
const db      = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

// ── register ─────────────────────────────────────────────────
// POST /api/auth/register
// Body: { username, email, password, phone, first_name, last_name, gender, date_of_birth }
const register = async (req, res) => {
  const { username, email, password, phone, first_name, last_name, gender, date_of_birth } = req.body;

  if (!username || !email || !password || !first_name || !last_name) {
    return sendError(res, 'username, email, password, first_name and last_name are required.', 400);
  }

  try {
    // Check duplicate email / username
    const [existing] = await db.query(
      'SELECT user_id FROM users WHERE email COLLATE utf8mb4_unicode_ci = ? OR username COLLATE utf8mb4_unicode_ci = ?',
      [email, username]
    );
    if (existing.length > 0) {
      return sendError(res, 'Email or username is already registered.', 409);
    }

    // Hash password
    const hashed = await bcrypt.hash(password, 10);

    // customer role_id = 2 (from seed data)
    const [userResult] = await db.query(
      `INSERT INTO users (role_id, username, email, password, phone, status)
       VALUES (2, ?, ?, ?, ?, 'active')`,
      [username, email, hashed, phone || null]
    );
    const newUserId = userResult.insertId;

    // Create customer profile
    await db.query(
      `INSERT INTO customers (user_id, first_name, last_name, gender, date_of_birth)
       VALUES (?, ?, ?, ?, ?)`,
      [newUserId, first_name, last_name, gender || null, date_of_birth || null]
    );

    return sendSuccess(res, { user_id: newUserId }, 'Registration successful.', 201);
  } catch (err) {
    console.error('register error:', err);
    return sendError(res, 'Registration failed.');
  }
};

// ── login ─────────────────────────────────────────────────────
// POST /api/auth/login
// Body: { email, password }
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return sendError(res, 'Email and password are required.', 400);
  }

  try {
    const [rows] = await db.query(
      `SELECT u.user_id, u.username, u.email, u.password, u.status,
              r.role_id, r.role_name
       FROM   users u
       JOIN   roles r ON u.role_id = r.role_id
       WHERE  u.email COLLATE utf8mb4_unicode_ci = ?
         AND  u.deleted_at IS NULL`,
      [email]
    );

    if (rows.length === 0) {
      return sendError(res, 'Invalid email or password.', 401);
    }

    const user = rows[0];

    if (user.status === 'banned') {
      return sendError(res, 'Your account has been banned.', 403);
    }
    if (user.status === 'inactive') {
      return sendError(res, 'Your account is inactive. Please contact support.', 403);
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return sendError(res, 'Invalid email or password.', 401);
    }

    // Sign JWT
    const token = jwt.sign(
      { user_id: user.user_id, role_id: user.role_id, role_name: user.role_name, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return sendSuccess(res, {
      token,
      user: {
        user_id:   user.user_id,
        username:  user.username,
        email:     user.email,
        role_name: user.role_name,
      }
    }, 'Login successful.');
  } catch (err) {
    console.error('login error:', err);
    return sendError(res, 'Login failed.');
  }
};

// ── getMe ─────────────────────────────────────────────────────
// GET /api/auth/me  (protected)
// Returns the logged-in user's profile.
const getMe = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT u.user_id, u.username, u.email, u.phone, u.status, u.created_at,
              r.role_name,
              c.customer_id, c.first_name, c.last_name, c.gender, c.date_of_birth
       FROM   users     u
       JOIN   roles     r ON u.role_id     = r.role_id
       LEFT JOIN customers c ON u.user_id  = c.user_id
       WHERE  u.user_id = ?`,
      [req.user.user_id]
    );

    if (rows.length === 0) {
      return sendError(res, 'User not found.', 404);
    }

    return sendSuccess(res, rows[0]);
  } catch (err) {
    console.error('getMe error:', err);
    return sendError(res);
  }
};

module.exports = { register, login, getMe };
