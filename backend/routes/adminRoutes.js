// ============================================================
//  routes/adminRoutes.js  (all routes: admin only)
// ============================================================
const express    = require('express');
const router     = express.Router();
const {
  getDashboardStats, getLowStock, updateStock,
  getAllUsers, updateUserStatus,
} = require('../controllers/adminController');
const { verifyToken, requireAdmin } = require('../middleware/auth');

router.use(verifyToken, requireAdmin); // every route here needs admin

router.get('/dashboard',                    getDashboardStats); // GET /api/admin/dashboard
router.get('/inventory/low-stock',          getLowStock);       // GET /api/admin/inventory/low-stock
router.put('/inventory/:product_id',        updateStock);       // PUT /api/admin/inventory/:product_id
router.get('/users',                        getAllUsers);        // GET /api/admin/users
router.put('/users/:user_id/status',        updateUserStatus);  // PUT /api/admin/users/:id/status

module.exports = router;
