const express = require('express');
const Swipe = require('../models/swipe');
const Match = require('../models/match');

const router = express.Router();

const toLegacyDirection = (direction) => {
  if (direction === 'like' || direction === 'right') return 'right';
  if (direction === 'dislike' || direction === 'left') return 'left';
  return null;
};

router.post('/swipe', async (req, res) => {
  const fromUserId = req.body.fromUserId || req.body.swiper;
  const toUserId = req.body.toUserId || req.body.swipedOn;
  const direction = toLegacyDirection(req.body.direction);

  if (!fromUserId || !toUserId || !direction) {
    return res.status(400).json({
      success: false,
      message: 'fromUserId, toUserId, and direction are required',
    });
  }

  try {
    const swipe = await Swipe.findOneAndUpdate(
      { swiper: fromUserId, swipedOn: toUserId },
      { $set: { direction } },
      { new: true, upsert: true }
    );

    let matchDoc = await Match.findOne({ users: { $all: [fromUserId, toUserId] } }).populate(
      'users',
      'name username email bio description profilePhoto location isProfileComplete profileCompleted interests'
    );

    if (!matchDoc && direction === 'right') {
      const reciprocalSwipe = await Swipe.findOne({
        swiper: toUserId,
        swipedOn: fromUserId,
        direction: 'right',
      });

      if (reciprocalSwipe) {
        matchDoc = await Match.create({ users: [fromUserId, toUserId] });
        matchDoc = await Match.findById(matchDoc._id).populate(
          'users',
          'name username email bio description profilePhoto location isProfileComplete profileCompleted interests'
        );
      }
    }

    const matchedUser =
      matchDoc?.users?.find((user) => String(user._id) !== String(fromUserId)) || null;

    res.status(201).json({
      success: true,
      matched: Boolean(matchDoc),
      message: matchDoc ? 'It is a match!' : 'Swipe recorded successfully',
      swipe: {
        id: swipe._id,
        fromUserId,
        toUserId,
        direction: direction === 'right' ? 'like' : 'dislike',
        createdAt: swipe.createdAt,
        updatedAt: swipe.updatedAt,
      },
      match: matchDoc,
      matchedUser,
    });
  } catch (err) {
    console.error('Swift match swipe error:', err.message);
    res.status(500).json({ success: false, message: 'Server error processing swipe' });
  }
});

router.get('/matches/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const matches = await Match.find({ users: userId }).populate(
      'users',
      'name username email bio description profilePhoto location isProfileComplete profileCompleted interests'
    );

    const profiles = matches
      .map((match) => match.users.find((user) => String(user._id) !== String(userId)))
      .filter(Boolean);

    res.json({ success: true, matches: profiles });
  } catch (err) {
    console.error('Swift match list error:', err.message);
    res.status(500).json({ success: false, message: 'Server error fetching matches' });
  }
});

router.delete('/reset/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [swipesDeleted, matchesDeleted] = await Promise.all([
      Swipe.deleteMany({ $or: [{ swiper: userId }, { swipedOn: userId }] }),
      Match.deleteMany({ users: userId }),
    ]);

    res.json({
      success: true,
      message: 'Match data reset successfully',
      deleted: {
        swipes: swipesDeleted.deletedCount,
        matches: matchesDeleted.deletedCount,
      },
    });
  } catch (err) {
    console.error('Swift match reset error:', err.message);
    res.status(500).json({ success: false, message: 'Server error resetting matches' });
  }
});

module.exports = router;
