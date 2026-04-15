const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const User = require('../models/user');

// CREATE: Add new user
router.post(
  '/',
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('username').optional().isString().withMessage('Username must be a string'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('domain').optional().isString().withMessage('Domain must be a string'),
    body('skills').isArray().withMessage('Skills must be an array'),
    body('interests').isArray().withMessage('Interests must be an array'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { name, username, email, domain, skills, interests } = req.body;

    try {
      const existingUser = await User.findOne(
        username ? { $or: [{ email }, { username }] } : { email }
      );
      if (existingUser) return res.status(409).json({ error: 'User already exists' });

      const newUser = new User({ name, username, email, domain, skills, interests });
      await newUser.save();

      res.status(201).json(newUser);
    } catch (err) {
      console.error('Create error:', err.message);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// READ: Get all users
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// READ: Get user by ID
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// UPDATE: Update user by ID
router.put(
  '/:id',
  [
    body('name').optional().notEmpty().withMessage('Name cannot be empty'),
    body('username').optional().isString().withMessage('Username must be a string'),
    body('email').optional().isEmail().withMessage('Email must be valid'),
    body('domain').optional().isString(),
    body('skills').optional().isArray(),
    body('interests').optional().isArray(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { password, ...updates } = req.body;
      const updatedUser = await User.findByIdAndUpdate(
        req.params.id,
        { $set: updates },
        { new: true }
      );
      if (!updatedUser) return res.status(404).json({ error: 'User not found' });

      res.json(updatedUser);
    } catch (err) {
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// DELETE: Remove user by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedUser = await User.findByIdAndDelete(req.params.id);
    if (!deletedUser) return res.status(404).json({ error: 'User not found' });

    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
