// ============================================================
//  app.js — Express application entry point
//  Online Shop System Backend
// ============================================================

require('dotenv').config();
const express      = require('express');
const cors         = require('cors');

// Route imports
const authRoutes    = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes    = require('./routes/cartRoutes');
const orderRoutes   = require('./routes/orderRoutes');
const adminRoutes   = require('./routes/adminRoutes');
const addressRoutes = require('./routes/addressRoutes');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Global Middleware ─────────────────────────────────────────
app.use(cors());                          // allow cross-origin requests from frontend
app.use(express.json());                  // parse JSON request bodies
app.use(express.urlencoded({ extended: true })); // parse form data

// ── API Routes ────────────────────────────────────────────────
app.use('/api/auth',      authRoutes);
app.use('/api/products',  productRoutes);
app.use('/api/cart',      cartRoutes);
app.use('/api/orders',    orderRoutes);
app.use('/api/admin',     adminRoutes);
app.use('/api/addresses', addressRoutes);

// ── Health Check ──────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Online Shop API is running.', timestamp: new Date() });
});

// ── 404 Handler ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found.` });
});

// ── Global Error Handler ──────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, message: 'Internal server error.' });
});

// ── Start Server ──────────────────────────────────────────────
// Guard prevents listen() from firing when required by tests
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀  Server running on http://localhost:${PORT}`);
    console.log(`📋  API base: http://localhost:${PORT}/api`);
  });
}

// ── Safety Net: catch unhandled promise rejections ────────────
// Prevents Node from crashing silently on missed await errors.
process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason);
});

module.exports = app;
