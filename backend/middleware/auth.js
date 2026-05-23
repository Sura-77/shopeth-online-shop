// ============================================================
//  middleware/auth.js
//  verifyToken  — checks JWT on every protected route
//  requireAdmin — additional guard for admin-only routes
// ============================================================

const jwt = require('jsonwebtoken');

// ── verifyToken ──────────────────────────────────────────────
// Reads the Authorization header, verifies the JWT, and
// attaches the decoded payload to req.user.
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Access denied. No token provided.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { user_id, role_id, role_name, username }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token.' });
  }
};

// ── requireAdmin ─────────────────────────────────────────────
// Must come AFTER verifyToken in the middleware chain.
// Blocks access unless the logged-in user has role 'admin'.
const requireAdmin = (req, res, next) => {
  if (req.user?.role_name !== 'admin') {
    return res.status(403).json({ success: false, message: 'Access denied. Admins only.' });
  }
  next();
};

module.exports = { verifyToken, requireAdmin };
