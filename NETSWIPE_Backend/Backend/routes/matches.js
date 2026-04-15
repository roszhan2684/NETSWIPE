// routes/matches.js
const express = require('express');
const router = express.Router();
const Match = require('../models/match');

// @route   GET /api/matches/:userId
// @desc    Get all matches for a user
router.get('/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const matches = await Match.find({ users: userId }).populate('users', 'name email');
    const matchedUsers = matches
      .map(match => match.users.find(u => u._id.toString() !== userId))
      .filter(Boolean);
    res.json(matchedUsers);
  } catch (err) {
    console.error('Match fetch error:', err);
    res.status(500).json({ error: 'Server error fetching matches' });
  }
});

module.exports = router;
