// ============================================================
//  routes/addressRoutes.js  (all routes require login)
// ============================================================
const express    = require('express');
const router     = express.Router();
const { getAddresses, addAddress, deleteAddress } = require('../controllers/addressController');
const { verifyToken } = require('../middleware/auth');

router.use(verifyToken); // all address routes require auth

router.get('/',     getAddresses);       // GET    /api/addresses
router.post('/',    addAddress);         // POST   /api/addresses
router.delete('/:id', deleteAddress);   // DELETE /api/addresses/:id

module.exports = router;
