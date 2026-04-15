// routes/messages.js
const express = require('express');
const router = express.Router();
const Message = require('../models/message');

// @route   POST /api/messages
// @desc    Send a message between two users
router.post('/', async (req, res) => {
  try {
    const { sender, receiver, text } = req.body;

    // Validate required fields
    if (!sender || !receiver || !text) {
      return res.status(400).json({
        error: 'Sender, receiver, and message text are required.'
      });
    }

    // Create and save the new message
    const newMessage = new Message({ sender, receiver, text });
    await newMessage.save();

    res.status(201).json({
      message: 'Message sent successfully',
      data: newMessage
    });
  } catch (err) {
    console.error('Message send error:', err);
    res.status(500).json({
      error: 'Server error while sending message'
    });
  }
});

// @route   GET /api/messages/:user1/:user2
// @desc    Retrieve all messages exchanged between two users
router.get('/:user1/:user2', async (req, res) => {
  const { user1, user2 } = req.params;

  try {
    const messages = await Message.find({
      $or: [
        { sender: user1, receiver: user2 },
        { sender: user2, receiver: user1 }
      ]
    }).sort({ createdAt: 1 });

    res.status(200).json({
      message: 'Messages retrieved successfully',
      data: messages
    });
  } catch (err) {
    console.error('Message fetch error:', err);
    res.status(500).json({
      error: 'Server error while retrieving messages'
    });
  }
});

module.exports = router;
