import axios from 'axios';

(async () => {
  try {
    const url: string = 'https://app.solacebank.net/';
    const response = await axios.get(url);

    const headers: Record<string, string> = response.headers;

    console.log('Validating headers for:', url);

    // Check Content-Security-Policy
    if (headers['content-security-policy']) {
      console.log('✅ Content-Security-Policy is present:', headers['content-security-policy']);
    } else {
      console.log('❌ Content-Security-Policy is missing.');
    }

    // Check Cache-Control
    if (headers['cache-control']) {
      console.log('✅ Cache-Control is present:', headers['cache-control']);
    } else {
      console.log('❌ Cache-Control is missing.');
    }

    // Check X-Content-Type-Options
    if (headers['x-content-type-options']) {
      console.log('✅ X-Content-Type-Options is present:', headers['x-content-type-options']);
    } else {
      console.log('❌ X-Content-Type-Options is missing.');
    }
  } catch (error: any) {
    console.error('Error validating headers:', error.message);
  }
})();
