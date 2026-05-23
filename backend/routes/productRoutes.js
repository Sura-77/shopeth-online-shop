// ============================================================
//  routes/productRoutes.js
// ============================================================
const express    = require('express');
const router     = express.Router();
const {
  getAllProducts, getProductById,
  createProduct, updateProduct, deleteProduct,
  getCategories,
} = require('../controllers/productController');
const { verifyToken, requireAdmin } = require('../middleware/auth');

// Public routes
router.get('/categories',  getCategories);   // GET /api/products/categories
router.get('/',            getAllProducts);   // GET /api/products
router.get('/:id',         getProductById);  // GET /api/products/:id

// Admin-only routes
router.post('/',    verifyToken, requireAdmin, createProduct);   // POST   /api/products
router.put('/:id',  verifyToken, requireAdmin, updateProduct);   // PUT    /api/products/:id
router.delete('/:id', verifyToken, requireAdmin, deleteProduct); // DELETE /api/products/:id

module.exports = router;
