const axios = require('axios');

(async () => {
  try {
    const url = 'https://app.solacebank.net/';
    const response = await axios.get(url);

    const headers = response.headers;

    console.log('Validating headers for:', url);

    // Check Content-Security-Policy
    if (headers['content-security-policy']) {
      console.log('✅ Content-Security-Policy:', headers['content-security-policy']);
    } else {
      console.error('❌ Content-Security-Policy is missing');
    }

    // Check Cache-Control
    if (headers['cache-control']) {
      console.log('✅ Cache-Control:', headers['cache-control']);
    } else {
      console.error('❌ Cache-Control is missing or empty');
    }

    // Check X-Content-Type-Options
    if (headers['x-content-type-options'] === 'nosniff') {
      console.log('✅ X-Content-Type-Options is set to nosniff');
    } else {
      console.error('❌ X-Content-Type-Options is missing or incorrect');
    }
  } catch (error) {
    console.error('Error fetching the URL:', error.message);
  }
})();
