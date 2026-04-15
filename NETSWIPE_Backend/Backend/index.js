const http = require('http');
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { Server } = require('socket.io');
require('dotenv').config();
const Message = require('./models/message');
const { createChatId } = require('./utils/chat');

const app = express(); // ✅ Initialize app first
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

// Middleware
app.use(cors({
  origin: '*', // Replace with frontend URL in production
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json()); // Parse JSON request bodies

// Route Imports
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const swipeRoutes = require('./routes/swipes');
const messageRoutes = require('./routes/messages');
const matchRoutes = require('./routes/matches');
const profileRoutes = require('./routes/profile');
const matchApiRoutes = require('./routes/match');
const chatRoutes = require('./routes/chat');

// Route Registrations
app.use('/api/auth', authRoutes);
app.use('/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/swipes', swipeRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/matches', matchRoutes);
app.use('/profile', profileRoutes);
app.use('/api/profile', profileRoutes);
app.use('/match', matchApiRoutes);
app.use('/api/match', matchApiRoutes);
app.use('/chat', chatRoutes);
app.use('/api/chat', chatRoutes);

// Test Route
app.get('/', (req, res) => {
  res.send('✅ NetSwipe backend is running');
});

// Fallback for undefined routes
app.use((req, res, next) => {
  res.status(404).json({ error: '❌ API endpoint not found' });
});

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI).then(() => {
  console.log('✅ MongoDB connected');
}).catch((err) => {
  console.error('❌ MongoDB connection error:', err);
});

io.on('connection', (socket) => {
  socket.on('join', ({ userId } = {}) => {
    if (!userId) return;
    socket.join(String(userId));
  });

  socket.on('send_message', async ({ fromUserId, toUserId, text } = {}) => {
    if (!fromUserId || !toUserId || !text) return;

    try {
      const message = await Message.create({
        sender: fromUserId,
        receiver: toUserId,
        fromUserId,
        toUserId,
        text,
        chatId: createChatId(fromUserId, toUserId),
      });

      const payload = message.toJSON();
      io.to(String(fromUserId)).emit('new_message', payload);
      io.to(String(toUserId)).emit('new_message', payload);
    } catch (err) {
      console.error('Socket message error:', err.message);
    }
  });
});

// Start Server
const PORT = process.env.PORT || 5001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
