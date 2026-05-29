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
│   └── sample_data.sql      # 36 products + seed data
├── backend/
│   ├── app.js
│   ├── config/db.js
│   ├── controllers/
│   ├── routes/
│   ├── middleware/
│   ├── utils/
│   └── tests/
└── frontend/
    ├── pages/
    ├── css/style.css
    └── js/api.js
```

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | sara@shopAdmin.com | test |
| Admin | john@shopAdmin.com | test |
| Customer | abel@email.com | test |
| Customer | meron@email.com | test |

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
