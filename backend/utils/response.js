// ============================================================
//  utils/response.js
//  Consistent JSON response shape across all endpoints:
//  { success, message, data }
// ============================================================

const sendSuccess = (res, data = null, message = 'OK', statusCode = 200) => {
  return res.status(statusCode).json({ success: true, message, data });
};

const sendError = (res, message = 'Something went wrong.', statusCode = 500) => {
  return res.status(statusCode).json({ success: false, message, data: null });
};

module.exports = { sendSuccess, sendError };
