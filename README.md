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
online shope system/
├── backend/                  # Node.js/Express REST API
│   ├── app.js
│   ├── config/db.js
│   ├── controllers/
│   ├── routes/
│   ├── middleware/
│   ├── utils/
│   └── tests/
├── frontend/                 # Static HTML/CSS/JS
│   ├── pages/
│   ├── css/style.css
│   └── js/api.js
├── schema_v2.sql             # Database schema (16 tables)
├── procedures.sql            # 5 stored procedures
├── triggers.sql              # 4 triggers
├── views.sql                 # 5 views
├── sample_data.sql           # Seed data
└── more_products.sql         # Additional 24 products
```

## Setup

### 1. Database
Run these SQL files in MySQL Workbench in order:
```
schema_v2.sql → procedures.sql → triggers.sql → views.sql → sample_data.sql → more_products.sql
```

Then fix demo passwords:
```sql
UPDATE users
SET password = '$2a$10$jieWQyLI9tURrpCPO6dvYe0osbZlz//PaoGGSg4bw94hYCP24L17a'
WHERE email IN (
  'sara@shopAdmin.com', 'john@shopAdmin.com', 'abel@email.com',
  'meron@email.com', 'kaleb@email.com', 'hana@email.com',
  'dawit@email.com', 'tigist@email.com'
);
```

### 2. Backend
```bash
cd backend
cp .env.example .env        # fill in your DB password and JWT secret
npm install
npm run dev                 # starts on http://localhost:3000
```

### 3. Frontend
Open with VS Code Live Server or:
```bash
cd frontend
python -m http.server 8080
# then open http://localhost:8080/pages/index.html
```

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | sara@shopAdmin.com | test |
| Customer | abel@email.com | test |

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
