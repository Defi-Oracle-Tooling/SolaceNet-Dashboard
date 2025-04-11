const helmet = require('helmet');

module.exports = function validateHeaders(app) {
  // Use Helmet to secure HTTP headers
  app.use(helmet());

  // Example: Add custom headers
  app.use((req, res, next) => {
    res.setHeader('X-Custom-Header', 'SecureApp');
    next();
  });

  console.log('Headers validated and secured.');
};
