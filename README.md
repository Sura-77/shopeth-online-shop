# ShopEth — Online Shop System

A full-stack e-commerce platform built as a Database class project. ShopEth simulates a real Ethiopian online marketplace with product browsing, cart management, order placement, coupon discounts, inventory tracking, and an admin dashboard.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Database | MySQL 8.x — 16 tables, 5 stored procedures, 4 triggers, 5 views |
| Backend | Node.js + Express.js REST API |
| Authentication | JSON Web Tokens (JWT) + bcryptjs |
| Frontend | HTML5 + CSS3 + Vanilla JavaScript + Bootstrap 5.3 |

## Features

- Product browsing with category filters, search, and pagination
- User registration and JWT-based login
- Shopping cart with quantity management
- Checkout with coupon/discount code support
- Order history and tracking
- Admin dashboard — sales stats, inventory alerts, order and user management
- Product detail page with image gallery and reviews
- Address management for delivery
- Soft-delete for products
- Review system — only verified buyers can review

## Project Structure

```
shopeth-online-shop/
├── database/
│   ├── schema_v2.sql        # All 16 tables
│   ├── procedures.sql       # 5 stored procedures
│   ├── triggers.sql         # 4 triggers
│   ├── views.sql            # 5 views
│   └── sample_data.sql      # 36 products + seed data (passwords pre-hashed)
├── backend/
│   ├── app.js               # Express entry point
│   ├── .env.example         # Environment variable template
│   ├── config/db.js         # MySQL connection pool
│   ├── controllers/         # Route handlers
│   ├── routes/              # API route definitions
│   ├── middleware/auth.js   # JWT verification
│   ├── utils/response.js    # Consistent response helpers
│   └── tests/api.test.js    # 43 API tests
└── frontend/
    ├── pages/               # index, login, register, cart, orders, product, admin
    ├── css/style.css        # Global design system
    └── js/api.js            # Centralized API client
```

## Prerequisites

- [Node.js](https://nodejs.org/) v18 or later
- [MySQL](https://dev.mysql.com/downloads/) 8.x
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) or any MySQL client
- [VS Code Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension (for the frontend)

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/Sura-77/shopeth-online-shop.git
cd shopeth-online-shop
```

### 2. Set up the database

Open MySQL Workbench and run the files in the `database/` folder **in this exact order**:

```
1. schema_v2.sql      ← creates the database and all 16 tables
2. procedures.sql     ← creates 5 stored procedures
3. triggers.sql       ← creates 4 triggers
4. views.sql          ← creates 5 views
5. sample_data.sql    ← inserts all seed data (passwords already hashed)
```

### 3. Configure the backend

```bash
cd backend
copy .env.example .env
```

Open `.env` and fill in your MySQL password and a JWT secret:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=online_shop_db
JWT_SECRET=any_long_random_string_here
JWT_EXPIRES_IN=7d
```

### 4. Install dependencies and start the backend

```bash
npm install
npm run dev
```

The API will be running at `http://localhost:3000/api`

### 5. Open the frontend

Open `frontend/pages/index.html` with **VS Code Live Server** (right-click → Open with Live Server).

> Do not open HTML files by double-clicking — the fetch calls to `localhost:3000` require HTTP, not `file://`.

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | sara@shopAdmin.com | test |
| Admin | john@shopAdmin.com | test |
| Customer | abel@email.com | test |
| Customer | meron@email.com | test |
| Customer | kaleb@email.com | test |
| Customer | hana@email.com | test |
| Customer | dawit@email.com | test |

## API Base URL

```
http://localhost:3000/api
```

## Running Tests

```bash
cd backend
npm test
```

43 tests covering Auth, Products, Cart, Orders, Addresses, and Admin endpoints.

## License

MIT — built for educational purposes.
