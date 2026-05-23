// ============================================================
//  routes/orderRoutes.js
// ============================================================
const express    = require('express');
const router     = express.Router();
const {
  createOrder, getMyOrders, getOrderById,
  getAllOrders, updateOrderStatus,
} = require('../controllers/orderController');
const { verifyToken, requireAdmin } = require('../middleware/auth');

router.use(verifyToken); // all order routes require auth

// Admin routes MUST come before /:id to avoid being shadowed
router.get('/admin/all',        requireAdmin, getAllOrders);      // GET /api/orders/admin/all
router.put('/admin/:id/status', requireAdmin, updateOrderStatus); // PUT /api/orders/admin/:id/status

// Customer routes
router.post('/create', createOrder);  // POST /api/orders/create
router.get('/',        getMyOrders);  // GET  /api/orders
router.get('/:id',     getOrderById); // GET  /api/orders/:id  ← must be last

module.exports = router;
