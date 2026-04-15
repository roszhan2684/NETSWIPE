const express = require('express');
const router = express.Router();
const Swipe = require('../models/swipe');
const Match = require('../models/match');
const User = require('../models/user');

// @route   POST /api/swipes
// @desc    Record a swipe and check for a match
router.post('/', async (req, res) => {
  const { swiper, swipedOn, direction } = req.body;

  // Validate input
  if (!swiper || !swipedOn || !['left', 'right'].includes(direction)) {
    return res.status(400).json({
      error: 'Invalid swipe data. Please provide valid swiper, swipedOn, and direction (left/right).'
    });
  }

  try {
    // Save the swipe
    const newSwipe = new Swipe({ swiper, swipedOn, direction });
    await newSwipe.save();

    // If the current swipe is "right", check if the other user also swiped right
    if (direction === 'right') {
      const reciprocalSwipe = await Swipe.findOne({
        swiper: swipedOn,
        swipedOn: swiper,
        direction: 'right'
      });

      if (reciprocalSwipe) {
        // Save the match
        const newMatch = new Match({
          users: [swiper, swipedOn]
        });
        await newMatch.save();

        return res.status(201).json({
          match: true,
          message: '🎉 It’s a match!',
          swipe: newSwipe,
          matchId: newMatch._id
        });
      }
    }

    // If no match yet
    res.status(201).json({
      match: false,
      message: 'Swipe recorded successfully',
      swipe: newSwipe
    });
  } catch (err) {
    console.error('Swipe creation error:', err);
    res.status(500).json({ error: 'Server error while processing the swipe.' });
  }
});

module.exports = router;
