// ============================================================
//  routes/cartRoutes.js  (all routes require login)
// ============================================================
const express    = require('express');
const router     = express.Router();
const {
  getCart, addToCart, updateCartItem, removeFromCart, clearCart,
} = require('../controllers/cartController');
const { verifyToken } = require('../middleware/auth');

router.use(verifyToken); // all cart routes require auth

router.get('/',                    getCart);          // GET    /api/cart
router.post('/add',                addToCart);        // POST   /api/cart/add
router.put('/update',              updateCartItem);   // PUT    /api/cart/update
router.delete('/remove/:cart_item_id', removeFromCart); // DELETE /api/cart/remove/:id
router.delete('/clear',            clearCart);        // DELETE /api/cart/clear

module.exports = router;
