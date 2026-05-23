// ============================================================
//  tests/api.test.js — ShopEth API Test Suite
//  Tests: Auth, Products, Cart, Orders, Addresses, Admin
//  Run: npm test
// ============================================================

const request = require('supertest');
const app     = require('../app');

// ── Shared state across tests ─────────────────────────────────
let customerToken = '';
let adminToken    = '';
let customerId    = 0;
let productId     = 0;
let cartItemId    = 0;
let addressId     = 0;
let orderId       = 0;
let cartId        = 0;

// ── Increase timeout for DB calls ────────────────────────────
jest.setTimeout(15000);

// ── Close DB pool after all tests ────────────────────────────
afterAll(async () => {
  const db = require('../config/db');
  await db.end();
});

// ══════════════════════════════════════════════════════════════
// 1. HEALTH CHECK
// ══════════════════════════════════════════════════════════════
describe('Health Check', () => {
  test('GET /api/health → 200 success', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.message).toMatch(/running/i);
  });
});

// ══════════════════════════════════════════════════════════════
// 2. AUTH
// ══════════════════════════════════════════════════════════════
describe('Auth — POST /api/auth/login', () => {
  test('Login with missing fields → 400', async () => {
    const res = await request(app).post('/api/auth/login').send({ email: 'abel@email.com' });
    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('Login with wrong password → 401', async () => {
    const res = await request(app).post('/api/auth/login')
      .send({ email: 'abel@email.com', password: 'wrongpassword' });
    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });

  test('Login as customer (abel) → 200 + token', async () => {
    const res = await request(app).post('/api/auth/login')
      .send({ email: 'abel@email.com', password: 'test' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.token).toBeDefined();
    expect(res.body.data.user.role_name).toBe('customer');
    customerToken = res.body.data.token;
  });

  test('Login as admin (sara) → 200 + admin token', async () => {
    const res = await request(app).post('/api/auth/login')
      .send({ email: 'sara@shopAdmin.com', password: 'test' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.role_name).toBe('admin');
    adminToken = res.body.data.token;
  });

  test('GET /api/auth/me without token → 401', async () => {
    const res = await request(app).get('/api/auth/me');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/auth/me with valid token → 200 + user data', async () => {
    const res = await request(app).get('/api/auth/me')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.email).toBe('abel@email.com');
    customerId = res.body.data.customer_id;
  });
});

// ══════════════════════════════════════════════════════════════
// 3. PRODUCTS
// ══════════════════════════════════════════════════════════════
describe('Products — GET /api/products', () => {
  test('GET /api/products → 200 + paginated list', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data.products)).toBe(true);
    expect(res.body.data.products.length).toBeGreaterThan(0);
    expect(res.body.data.pagination).toBeDefined();
    productId = res.body.data.products[0].product_id;
  });

  test('GET /api/products?search=samsung → returns Samsung product', async () => {
    const res = await request(app).get('/api/products?search=samsung');
    expect(res.statusCode).toBe(200);
    expect(res.body.data.products.length).toBeGreaterThan(0);
    expect(res.body.data.products[0].product_name.toLowerCase()).toContain('samsung');
  });

  test('GET /api/products?stock_status=in_stock → only in_stock items', async () => {
    const res = await request(app).get('/api/products?stock_status=in_stock');
    expect(res.statusCode).toBe(200);
    res.body.data.products.forEach(p => expect(p.stock_status).toBe('in_stock'));
  });

  test('GET /api/products?page=abc → safe fallback, no crash', async () => {
    const res = await request(app).get('/api/products?page=abc&limit=xyz');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('GET /api/products/categories → 200 + category list', async () => {
    const res = await request(app).get('/api/products/categories');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  test('GET /api/products/:id → 200 + product detail', async () => {
    const res = await request(app).get(`/api/products/${productId}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.product).toBeDefined();
    expect(res.body.data.images).toBeDefined();
    expect(res.body.data.reviews).toBeDefined();
  });

  test('GET /api/products/99999 → 404', async () => {
    const res = await request(app).get('/api/products/99999');
    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
  });

  test('POST /api/products without auth → 401', async () => {
    const res = await request(app).post('/api/products')
      .send({ product_name: 'Test', price: 100, sku: 'TST-001', category_id: 1 });
    expect(res.statusCode).toBe(401);
  });

  test('POST /api/products as customer → 403', async () => {
    const res = await request(app).post('/api/products')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ product_name: 'Test', price: 100, sku: 'TST-001', category_id: 1 });
    expect(res.statusCode).toBe(403);
  });
});

// ══════════════════════════════════════════════════════════════
// 4. ADDRESSES
// ══════════════════════════════════════════════════════════════
describe('Addresses — /api/addresses', () => {
  test('GET /api/addresses without auth → 401', async () => {
    const res = await request(app).get('/api/addresses');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/addresses with auth → 200 + array', async () => {
    const res = await request(app).get('/api/addresses')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  test('POST /api/addresses with missing fields → 400', async () => {
    const res = await request(app).post('/api/addresses')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ street: 'Bole Road' }); // missing city and country
    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('POST /api/addresses → 201 + new address_id', async () => {
    const res = await request(app).post('/api/addresses')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ street: 'Test Street 42', city: 'Addis Ababa', country: 'Ethiopia', address_type: 'both' });
    expect(res.statusCode).toBe(201);
    expect(res.body.data.address_id).toBeDefined();
    addressId = res.body.data.address_id;
  });

  test('DELETE /api/addresses/:id → 200', async () => {
    const res = await request(app).delete(`/api/addresses/${addressId}`)
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('DELETE /api/addresses/99999 → 404', async () => {
    const res = await request(app).delete('/api/addresses/99999')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(404);
  });
});

// ══════════════════════════════════════════════════════════════
// 5. CART
// ══════════════════════════════════════════════════════════════
describe('Cart — /api/cart', () => {
  test('GET /api/cart without auth → 401', async () => {
    const res = await request(app).get('/api/cart');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/cart with auth → 200', async () => {
    const res = await request(app).get('/api/cart')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    if (res.body.data.cart) cartId = res.body.data.cart.cart_id;
  });

  test('POST /api/cart/add without product_id → 400', async () => {
    const res = await request(app).post('/api/cart/add')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ quantity: 1 });
    expect(res.statusCode).toBe(400);
  });

  test('POST /api/cart/add with quantity 0 → 400', async () => {
    const res = await request(app).post('/api/cart/add')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ product_id: productId, quantity: 0 });
    expect(res.statusCode).toBe(400);
  });

  test('POST /api/cart/add valid product → 200', async () => {
    const res = await request(app).post('/api/cart/add')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ product_id: productId, quantity: 1 });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('GET /api/cart after add → has items', async () => {
    const res = await request(app).get('/api/cart')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.items.length).toBeGreaterThan(0);
    cartItemId = res.body.data.items[0].cart_item_id;
    cartId     = res.body.data.cart.cart_id;
  });

  test('PUT /api/cart/update → 200', async () => {
    const res = await request(app).put('/api/cart/update')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ cart_item_id: cartItemId, quantity: 2 });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('DELETE /api/cart/remove/:id → 200', async () => {
    const res = await request(app).delete(`/api/cart/remove/${cartItemId}`)
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });
});

// ══════════════════════════════════════════════════════════════
// 6. ORDERS
// ══════════════════════════════════════════════════════════════
describe('Orders — /api/orders', () => {
  test('GET /api/orders without auth → 401', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/orders with auth → 200 + array', async () => {
    const res = await request(app).get('/api/orders')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    if (res.body.data.length > 0) orderId = res.body.data[0].order_id;
  });

  test('GET /api/orders/:id (own order) → 200', async () => {
    if (!orderId) return;
    const res = await request(app).get(`/api/orders/${orderId}`)
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.order).toBeDefined();
  });

  test('POST /api/orders/create with missing fields → 400', async () => {
    const res = await request(app).post('/api/orders/create')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ cart_id: 1 }); // missing address_id
    expect(res.statusCode).toBe(400);
  });
});

// ══════════════════════════════════════════════════════════════
// 7. ADMIN
// ══════════════════════════════════════════════════════════════
describe('Admin — /api/admin', () => {
  test('GET /api/admin/dashboard without auth → 401', async () => {
    const res = await request(app).get('/api/admin/dashboard');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/admin/dashboard as customer → 403', async () => {
    const res = await request(app).get('/api/admin/dashboard')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(res.statusCode).toBe(403);
  });

  test('GET /api/admin/dashboard as admin → 200 + stats', async () => {
    const res = await request(app).get('/api/admin/dashboard')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.products).toBeDefined();
    expect(res.body.data.orders).toBeDefined();
    expect(res.body.data.customers).toBeDefined();
  });

  test('GET /api/admin/inventory/low-stock as admin → 200 + array', async () => {
    const res = await request(app).get('/api/admin/inventory/low-stock')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  test('GET /api/admin/users as admin → 200 + user list', async () => {
    const res = await request(app).get('/api/admin/users')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  test('PUT /api/admin/inventory/:id with invalid quantity → 400', async () => {
    const res = await request(app).put(`/api/admin/inventory/${productId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ quantity: -5 });
    expect(res.statusCode).toBe(400);
  });

  test('GET /api/orders/admin/all as admin → 200 + orders', async () => {
    const res = await request(app).get('/api/orders/admin/all')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data.orders)).toBe(true);
  });

  test('GET /api/orders/admin/all?page=abc → safe fallback', async () => {
    const res = await request(app).get('/api/orders/admin/all?page=abc')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
  });
});

// ══════════════════════════════════════════════════════════════
// 8. 404 HANDLER
// ══════════════════════════════════════════════════════════════
describe('404 Handler', () => {
  test('GET /api/nonexistent → 404', async () => {
    const res = await request(app).get('/api/nonexistent');
    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
  });
});
