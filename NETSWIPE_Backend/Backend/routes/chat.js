const express = require('express');
const Message = require('../models/message');
const { createChatId } = require('../utils/chat');

const router = express.Router();

router.get('/history/:otherUserId', async (req, res) => {
  const { otherUserId } = req.params;
  const { me } = req.query;
  const limit = Number(req.query.limit || 200);

  if (!me) {
    return res.status(400).json({ success: false, message: 'me query parameter is required' });
  }

  try {
    const chatId = createChatId(me, otherUserId);
    const messages = await Message.find({ chatId })
      .sort({ createdAt: 1 })
      .limit(Number.isNaN(limit) ? 200 : limit);

    res.json({ success: true, chatId, messages });
  } catch (err) {
    console.error('Chat history error:', err.message);
    res.status(500).json({ success: false, message: 'Server error fetching chat history' });
  }
});

router.delete('/reset/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await Message.deleteMany({
      $or: [
        { sender: userId },
        { receiver: userId },
        { fromUserId: userId },
        { toUserId: userId },
      ],
    });

    res.json({
      success: true,
      message: 'Chat history reset successfully',
      deletedMessages: result.deletedCount,
    });
  } catch (err) {
    console.error('Chat reset error:', err.message);
    res.status(500).json({ success: false, message: 'Server error resetting chat history' });
  }
});

module.exports = router;
