
const bcrypt = require('bcryptjs');
const db = require('./db');
const readline = require('node:readline');

async function main() {
  const email = 'marlboro882011@gmail.com';

  const [users] = await db.execute(
    'SELECT password_hash FROM users WHERE email = ?',
    [email]
  );

  if (users.length === 0) {
    console.log('Account not found');
    await db.end();
    return;
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  rl.question('Enter registered password: ', async (password) => {
    try {
      const valid = await bcrypt.compare(
        password,
        users[0].password_hash
      );

      console.log(
        valid ? 'Password correct!' : 'Password incorrect!'
      );
    } finally {
      rl.close();
      await db.end();
    }
  });
}

main().catch((error) => {
  console.error('Check failed:', error.message);
  process.exitCode = 1;
});
