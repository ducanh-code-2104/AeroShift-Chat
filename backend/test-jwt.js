
require('dotenv').config();

const jwt = require('jsonwebtoken');

const token = jwt.sign(
  {
    userId: 1,
    role: 'technician'
  },
  process.env.JWT_SECRET,
  {
    expiresIn: '2h',
    algorithm: 'HS256'
  }
);

const decoded = jwt.verify(
  token,
  process.env.JWT_SECRET,
  { algorithms: ['HS256'] }
);

console.log('JWT created:', Boolean(token));
console.log('JWT verified:', decoded.userId === 1);
console.log('Role:', decoded.role);
