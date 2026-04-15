const express = require('express');
const User = require('../models/user');
const Swipe = require('../models/swipe');
const Match = require('../models/match');
const Message = require('../models/message');

const router = express.Router();

const normalizeProfile = (user) => {
  const profile = user.toJSON ? user.toJSON() : user;
  return {
    ...profile,
    bio: profile.bio || profile.description || '',
    description: profile.description || profile.bio || '',
    isProfileComplete: Boolean(profile.isProfileComplete || profile.profileCompleted),
    profileCompleted: Boolean(profile.profileCompleted || profile.isProfileComplete),
  };
};

router.get('/', async (_req, res) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });
    res.json({ success: true, users: users.map(normalizeProfile) });
  } catch (err) {
    console.error('Profile list error:', err.message);
    res.status(500).json({ success: false, message: 'Server error fetching profiles' });
  }
});

router.get('/me', async (req, res) => {
  const userId = req.query.userId || req.query.id;

  if (!userId) {
    return res.status(400).json({ success: false, message: 'userId is required' });
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, user: normalizeProfile(user) });
  } catch (err) {
    console.error('Profile fetch error:', err.message);
    res.status(500).json({ success: false, message: 'Server error fetching profile' });
  }
});

router.post('/update', async (req, res) => {
  const userId = req.body.userId || req.body.id || req.body._id;

  if (!userId) {
    return res.status(400).json({ success: false, message: 'userId is required' });
  }

  const updates = { ...req.body };
  delete updates.userId;
  delete updates.id;
  delete updates._id;
  delete updates.password;

  if (updates.bio && !updates.description) {
    updates.description = updates.bio;
  }

  if (updates.description && !updates.bio) {
    updates.bio = updates.description;
  }

  if (typeof updates.isProfileComplete === 'boolean' && typeof updates.profileCompleted !== 'boolean') {
    updates.profileCompleted = updates.isProfileComplete;
  }

  if (typeof updates.profileCompleted === 'boolean' && typeof updates.isProfileComplete !== 'boolean') {
    updates.isProfileComplete = updates.profileCompleted;
  }

  try {
    const user = await User.findByIdAndUpdate(userId, { $set: updates }, { new: true });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      message: 'Profile updated',
      user: normalizeProfile(user),
    });
  } catch (err) {
    console.error('Profile update error:', err.message);
    res.status(500).json({ success: false, message: 'Server error updating profile' });
  }
});

router.delete('/delete/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    await Promise.all([
      Swipe.deleteMany({ $or: [{ swiper: userId }, { swipedOn: userId }] }),
      Match.deleteMany({ users: userId }),
      Message.deleteMany({
        $or: [
          { sender: userId },
          { receiver: userId },
          { fromUserId: userId },
          { toUserId: userId },
        ],
      }),
    ]);

    res.json({ success: true, message: 'Profile deleted successfully' });
  } catch (err) {
    console.error('Profile delete error:', err.message);
    res.status(500).json({ success: false, message: 'Server error deleting profile' });
  }
});

module.exports = router;
