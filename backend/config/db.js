// ============================================================
//  config/db.js — MySQL connection pool
//  Uses mysql2/promise for async/await support
// ============================================================

const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host:               process.env.DB_HOST     || 'localhost',
  port:               process.env.DB_PORT     || 3306,
  user:               process.env.DB_USER     || 'root',
  password:           process.env.DB_PASSWORD || '',
  database:           process.env.DB_NAME     || 'online_shop_db',
  waitForConnections: true,
  connectionLimit:    10,       // max simultaneous connections
  queueLimit:         0,        // unlimited queue
  timezone:           '+00:00', // store datetimes as UTC
  charset:            'utf8mb4_unicode_ci', // match the DB table collation
});

// Test the connection once on startup
pool.getConnection()
  .then(conn => {
    console.log('✅  MySQL connected — pool ready');
    conn.release();
  })
  .catch(err => {
    console.error('❌  MySQL connection failed:', err.message);
    process.exit(1); // crash early if DB is unreachable
  });

module.exports = pool;
