// ============================================================
//  js/api.js — Centralized API client
//  All fetch calls go through here so the base URL and
//  auth token are handled in one place.
// ============================================================

const API_BASE = 'http://localhost:3000/api';

// ── Token helpers ─────────────────────────────────────────────
const getToken  = ()         => localStorage.getItem('token');
const getUser   = ()         => JSON.parse(localStorage.getItem('user') || 'null');
const saveAuth  = (token, user) => {
  localStorage.setItem('token', token);
  localStorage.setItem('user',  JSON.stringify(user));
};
const clearAuth = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
};
const isLoggedIn = () => !!getToken();
const isAdmin    = () => getUser()?.role_name === 'admin';

// ── Core fetch wrapper ────────────────────────────────────────
async function request(endpoint, options = {}) {
  const token = getToken();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${endpoint}`, { ...options, headers });
  const data = await res.json();

  // Auto-logout ONLY on 401 for protected routes (not for login/register endpoints)
  const isAuthEndpoint = endpoint === '/auth/login' || endpoint === '/auth/register';
  if (res.status === 401 && !isAuthEndpoint) {
    clearAuth();
    window.location.href = 'login.html';
    return;
  }

  return data;
}

// ── Shorthand methods ─────────────────────────────────────────
const get    = (endpoint)       => request(endpoint, { method: 'GET' });
const post   = (endpoint, body) => request(endpoint, { method: 'POST',   body: JSON.stringify(body) });
const put    = (endpoint, body) => request(endpoint, { method: 'PUT',    body: JSON.stringify(body) });
const del    = (endpoint)       => request(endpoint, { method: 'DELETE' });

// ── Auth ──────────────────────────────────────────────────────
const auth = {
  register: (data)    => post('/auth/register', data),
  login:    (data)    => post('/auth/login',    data),
  me:       ()        => get('/auth/me'),
  logout:   ()        => { clearAuth(); window.location.href = 'login.html'; },
};

// ── Products ──────────────────────────────────────────────────
const products = {
  getAll:       (params = {}) => get('/products?' + new URLSearchParams(params).toString()),
  getById:      (id)          => get(`/products/${id}`),
  getCategories:()            => get('/products/categories'),
  create:       (data)        => post('/products', data),
  update:       (id, data)    => put(`/products/${id}`, data),
  delete:       (id)          => del(`/products/${id}`),
};

// ── Cart ──────────────────────────────────────────────────────
const cart = {
  get:    ()           => get('/cart'),
  add:    (product_id, quantity) => post('/cart/add', { product_id, quantity }),
  update: (cart_item_id, quantity) => put('/cart/update', { cart_item_id, quantity }),
  remove: (cart_item_id) => del(`/cart/remove/${cart_item_id}`),
  clear:  ()           => del('/cart/clear'),
};

// ── Orders ────────────────────────────────────────────────────
const orders = {
  create:    (data)   => post('/orders/create', data),
  getAll:    ()       => get('/orders'),
  getById:   (id)     => get(`/orders/${id}`),
  // admin
  adminAll:  (params) => get('/orders/admin/all?' + new URLSearchParams(params).toString()),
  updateStatus: (id, order_status) => put(`/orders/admin/${id}/status`, { order_status }),
};

// ── Addresses ─────────────────────────────────────────────────
const addresses = {
  getAll: ()       => get('/addresses'),
  add:    (data)   => post('/addresses', data),
  delete: (id)     => del(`/addresses/${id}`),
};
const admin = {
  dashboard:   ()           => get('/admin/dashboard'),
  lowStock:    ()           => get('/admin/inventory/low-stock'),
  updateStock: (product_id, quantity) => put(`/admin/inventory/${product_id}`, { quantity }),
  getUsers:    ()           => get('/admin/users'),
  updateUserStatus: (user_id, status) => put(`/admin/users/${user_id}/status`, { status }),
};

// ── Cart badge helper (used in navbar across all pages) ───────
async function refreshCartBadge() {
  const badge = document.getElementById('cart-count');
  if (!badge || !isLoggedIn()) return;
  try {
    const res = await cart.get();
    if (res?.success) {
      const count = res.data.items?.length || 0;
      badge.textContent = count;
      badge.classList.toggle('hidden', count === 0);
    }
  } catch { /* silent */ }
}

// ── Navbar auth state helper ──────────────────────────────────
function renderNavAuth() {
  const container = document.getElementById('nav-auth-links');
  if (!container) return;
  const user = getUser();
  if (user) {
    container.innerHTML = `
      <span style="color:rgba(255,255,255,.6);font-size:.85rem;">Hi, ${user.username}</span>
      ${user.role_name === 'admin'
        ? `<a href="admin.html" class="btn-nav">Admin</a>`
        : `<a href="orders.html" class="btn-nav outline">My Orders</a>`}
      <button class="btn-nav" onclick="auth.logout()">Logout</button>
    `;
  } else {
    container.innerHTML = `
      <a href="login.html"    class="btn-nav outline">Login</a>
      <a href="register.html" class="btn-nav">Register</a>
    `;
  }
}
