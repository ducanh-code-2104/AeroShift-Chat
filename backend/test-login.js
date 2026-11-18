
const http = require('http');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Email: ', (email) => {
  rl.question('Password: ', (password) => {
    rl.close();

    const body = JSON.stringify({ email, password });

    const req = http.request({
      hostname: '127.0.0.1',
      port: 3000,
      path: '/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      }
    }, (res) => {
      let response = '';

      res.on('data', chunk => response += chunk);

      res.on('end', () => {
        try {
          const data = JSON.parse(response);

          console.log('HTTP Status:', res.statusCode);
          console.log('Message:', data.message);
          console.log('JWT Token received:', Boolean(data.token));
console.log('Response fields:', Object.keys(data));
        } catch {
          console.log('Invalid JSON response');
        }
      });
    });

    req.on('error', console.error);
    req.end(body);
  });
});
