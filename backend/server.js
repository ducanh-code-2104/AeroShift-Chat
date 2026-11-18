
require('dotenv').config();

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Cho phép nhận dữ liệu JSON
app.use(express.json());

// API kiểm tra server
app.get('/', (req, res) => {
  res.json({
    message: 'AeroShift Chat Backend is running!'
  });
});

// API đăng ký tài khoản
app.post('/register', async (req, res) => {
  try {
    const {
      full_name,
      employee_code,
      email,
      password
    } = req.body || {};

    // Kiểm tra dữ liệu đầu vào
    if (
      typeof full_name !== 'string' ||
      typeof employee_code !== 'string' ||
      typeof email !== 'string' ||
      typeof password !== 'string' ||
      !full_name.trim() ||
      !employee_code.trim() ||
      !email.trim() ||
      !password
    ) {
      return res.status(400).json({
        message: 'Please fill in all fields'
      });
    }

    const name = full_name.trim();
    const code = employee_code.trim();
    const userEmail = email.trim().toLowerCase();

    if (
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userEmail)
    ) {
      return res.status(400).json({
        message: 'Invalid email address'
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        message: 'Password must have at least 8 characters'
      });
    }

    if (
      name.length > 100 ||
      code.length > 30 ||
      userEmail.length > 150
    ) {
      return res.status(400).json({
        message: 'Registration information is too long'
      });
    }

    // Mã hóa mật khẩu
    const passwordHash = await bcrypt.hash(password, 12);

    // Lưu tài khoản vào MySQL
    const [result] = await db.execute(
      `INSERT INTO users
       (full_name, employee_code, email, password_hash)
       VALUES (?, ?, ?, ?)`,
      [name, code, userEmail, passwordHash]
    );

    res.status(201).json({
      message: 'Registration successful!',
      user_id: result.insertId
    });

  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        message: 'Email or employee code already exists'
      });
    }

    console.error('Registration error:', error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Khởi động máy chủ

 // API đăng nhập tài khoản
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};

    // Kiểm tra dữ liệu
    if (
      typeof email !== 'string' ||
      typeof password !== 'string' ||
      !email.trim() ||
      !password
    ) {
      return res.status(400).json({
        message: 'Please enter email and password'
      });
    }

    // Tìm tài khoản trong MySQL
    const [users] = await db.execute(
      `SELECT user_id, full_name, email,
              employee_code, role, password_hash
       FROM users
       WHERE email = ?
       LIMIT 1`,
      [email.trim().toLowerCase()]
    );

    // Không tiết lộ email có tồn tại hay không
    if (users.length === 0) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    const user = users[0];

    // So sánh mật khẩu với mật khẩu đã mã hóa
    const isValid = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!isValid) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    
    // Tạo JWT token sau khi xác thực thành công
    const token = jwt.sign(
      {
        userId: user.user_id,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '2h',
        algorithm: 'HS256'
      }
    );

    // Trả token và thông tin kỹ thuật viên
    return res.status(200).json({
      message: 'Login successful!',
      token: token,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        employee_code: user.employee_code,
        email: user.email,
        role: user.role
      }
    });


  } catch (error) {
    console.error('Login error:', error);

    return res.status(500).json({
      message: 'Internal server error'
    });
  }
});

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];

  const token = authHeader?.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      message: 'Access token required'
    });
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET,
      { algorithms: ['HS256'] }
    );

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({
      message: 'Invalid or expired token'
    });
  }
}

app.get('/users', authenticateToken, async (req, res) => {

  try {
    const [users] = await db.query(
      `SELECT user_id, full_name, employee_code, role
       FROM users
       ORDER BY full_name ASC`
    );

    res.status(200).json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      message: 'Server error'
    });
  }
});

app.post('/messages', authenticateToken, async (req, res) => {
  const senderId = req.user.userId;
  const { receiver_id, content } = req.body;

  const receiverId = Number(receiver_id);

  if (
    !Number.isSafeInteger(receiverId) ||
    receiverId <= 0 ||
    receiverId === senderId ||
    typeof content !== 'string' ||
    !content.trim() ||
    content.length > 5000
  ) {
    return res.status(400).json({
      message: 'Invalid receiver or message content'
    });
  }

  const messageContent = content.trim();

  try {
    const [receivers] = await db.query(
      'SELECT user_id FROM users WHERE user_id = ?',
      [receiverId]
    );

    if (receivers.length === 0) {
      return res.status(404).json({
        message: 'Receiver not found'
      });
    }

    const user1Id = Math.min(senderId, receiverId);
    const user2Id = Math.max(senderId, receiverId);

    const [conversations] = await db.query(
      `SELECT conversation_id
       FROM conversations
       WHERE user1_id = ? AND user2_id = ?
       LIMIT 1`,
      [user1Id, user2Id]
    );

    let conversationId;

    if (conversations.length > 0) {
      conversationId = conversations[0].conversation_id;
    } else {
      const [result] = await db.query(
        `INSERT INTO conversations (user1_id, user2_id)
         VALUES (?, ?)`,
        [user1Id, user2Id]
      );

      conversationId = result.insertId;
    }

    const [result] = await db.query(
      `INSERT INTO messages
       (conversation_id, sender_id, content)
       VALUES (?, ?, ?)`,
      [conversationId, senderId, messageContent]
    );

    return res.status(201).json({
      message: 'Message sent successfully',
      message_id: result.insertId,
      conversation_id: conversationId
    });

  } catch (error) {
    console.error('Send message error:', error);

    return res.status(500).json({
      message: 'Server error'
    });
  }
});


app.get('/messages/:conversationId', authenticateToken, async (req, res) => {
  const conversationId = Number(req.params.conversationId);
  const userId = Number(req.user.userId);

  if (!Number.isSafeInteger(conversationId) || conversationId <= 0) {
    return res.status(400).json({
      message: 'Invalid conversation ID'
    });
  }

  try {
    const [conversations] = await db.query(
      `SELECT conversation_id
       FROM conversations
       WHERE conversation_id = ?
         AND (user1_id = ? OR user2_id = ?)`,
      [conversationId, userId, userId]
    );

    if (conversations.length === 0) {
      return res.status(404).json({
        message: 'Conversation not found'
      });
    }

    const [messages] = await db.query(
      `SELECT message_id, conversation_id,
              sender_id, content, sent_at, is_read
       FROM messages
       WHERE conversation_id = ?
       ORDER BY sent_at ASC, message_id ASC`,
      [conversationId]
    );

    return res.status(200).json(messages);

  } catch (error) {
    console.error('Get messages error:', error);

    return res.status(500).json({
      message: 'Server error'
    });
  }
});

app.get('/conversations/with/:userId', authenticateToken, async (req, res) => {
  const currentUserId = Number(req.user.userId);
  const otherUserId = Number(req.params.userId);

  if (
    !Number.isSafeInteger(otherUserId) ||
    otherUserId <= 0 ||
    otherUserId === currentUserId
  ) {
    return res.status(400).json({
      message: 'Invalid user ID'
    });
  }

  try {
    const [users] = await db.query(
      'SELECT user_id FROM users WHERE user_id = ?',
      [otherUserId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: 'User not found'
      });
    }

    const [conversations] = await db.query(
      `SELECT conversation_id
       FROM conversations
       WHERE (user1_id = ? AND user2_id = ?)
          OR (user1_id = ? AND user2_id = ?)
       ORDER BY conversation_id ASC
       LIMIT 1`,
      [currentUserId, otherUserId, otherUserId, currentUserId]
    );

    if (conversations.length === 0) {
      return res.status(200).json({
        conversation_id: null
      });
    }

    return res.status(200).json({
      conversation_id: conversations[0].conversation_id
    });

  } catch (error) {
    console.error('Get conversation error:', error);

    return res.status(500).json({
      message: 'Server error'
    });
  }
});

 
app.listen(PORT, '127.0.0.1', () => {
  console.log(
    `AeroShift Chat Server running at http://localhost:${PORT}`
  );
});


