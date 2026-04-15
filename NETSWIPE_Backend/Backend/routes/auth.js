const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/user');
const { isEmailConfigured, sendOtpEmail } = require('../utils/mailer');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'development-secret-change-me';
const JWT_EXPIRES_IN = '7d';
const OTP_TTL_MS = 10 * 60 * 1000;

const createOtp = () => String(Math.floor(100000 + Math.random() * 900000));

const buildAuthResponse = (user, token, extra = {}) => ({
  success: true,
  token,
  userId: user._id,
  email: user.email,
  username: user.username,
  user: user.toJSON(),
  ...extra,
});

const createToken = (user) =>
  jwt.sign(
    {
      userId: user._id,
      email: user.email,
      username: user.username,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );

router.post(
  '/register',
  [
    body('username').trim().notEmpty().withMessage('Username is required'),
    body('email').trim().isEmail().withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    body('name').optional().trim().isString(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const username = req.body.username.trim();
    const email = req.body.email.trim().toLowerCase();
    const displayName = req.body.name?.trim() || username;
    const { password } = req.body;

    try {
      const existingUser = await User.findOne({
        $or: [{ email }, { username }],
      });

      if (existingUser) {
        return res.status(409).json({
          success: false,
          error:
            existingUser.email === email
              ? 'An account with that email already exists'
              : 'That username is already taken',
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const otpCode = createOtp();
      const user = await User.create({
        name: displayName,
        username,
        email,
        password: hashedPassword,
        otpCode,
        otpExpires: new Date(Date.now() + OTP_TTL_MS),
      });

      let otpSent = false;
      let otpDeliveryMessage = 'OTP generated';

      try {
        const delivery = await sendOtpEmail({
          to: email,
          username,
          otp: otpCode,
        });
        otpSent = delivery.sent;
        if (delivery.reason) {
          otpDeliveryMessage = delivery.reason;
        } else if (delivery.sent) {
          otpDeliveryMessage = 'OTP sent to email';
        }
      } catch (emailErr) {
        console.error('OTP email send error:', emailErr.message);
        otpDeliveryMessage = 'OTP email delivery failed';
      }

      const token = createToken(user);
      res.status(201).json(
        buildAuthResponse(user, token, {
          message: 'Registration successful',
          otpRequired: true,
          otpSent,
          otpDeliveryMessage,
          otp: process.env.NODE_ENV === 'production' && otpSent ? undefined : otpCode,
        })
      );
    } catch (err) {
      console.error('Register error:', err.message);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  }
);

router.post(
  '/verify-otp',
  [
    body('otp').trim().notEmpty().withMessage('OTP is required'),
    body('email').optional().trim().isEmail(),
    body('userId').optional().trim().isString(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { otp, userId } = req.body;
    const email = req.body.email?.trim().toLowerCase();

    if (!email && !userId) {
      return res.status(400).json({
        success: false,
        error: 'email or userId is required',
      });
    }

    try {
      const user = await User.findOne(email ? { email } : { _id: userId }).select(
        '+otpCode +otpExpires'
      );

      if (!user) {
        return res.status(404).json({ success: false, error: 'User not found' });
      }

      if (!user.otpCode || user.otpCode !== otp) {
        return res.status(400).json({ success: false, error: 'Invalid OTP' });
      }

      if (!user.otpExpires || user.otpExpires.getTime() < Date.now()) {
        return res.status(400).json({ success: false, error: 'OTP has expired' });
      }

      user.isVerified = true;
      user.otpCode = null;
      user.otpExpires = null;
      await user.save();

      const token = createToken(user);
      res.json(buildAuthResponse(user, token, { message: 'OTP verified successfully' }));
    } catch (err) {
      console.error('Verify OTP error:', err.message);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  }
);

router.post(
  '/resend-otp',
  [
    body('email').optional().trim().isEmail(),
    body('userId').optional().trim().isString(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { userId } = req.body;
    const email = req.body.email?.trim().toLowerCase();

    if (!email && !userId) {
      return res.status(400).json({
        success: false,
        error: 'email or userId is required',
      });
    }

    try {
      const user = await User.findOne(email ? { email } : { _id: userId }).select(
        '+otpCode +otpExpires'
      );

      if (!user) {
        return res.status(404).json({ success: false, error: 'User not found' });
      }

      const otpCode = createOtp();
      user.otpCode = otpCode;
      user.otpExpires = new Date(Date.now() + OTP_TTL_MS);
      await user.save();

      let otpSent = false;
      let otpDeliveryMessage = 'OTP generated';

      try {
        const delivery = await sendOtpEmail({
          to: user.email,
          username: user.username,
          otp: otpCode,
        });
        otpSent = delivery.sent;
        if (delivery.reason) {
          otpDeliveryMessage = delivery.reason;
        } else if (delivery.sent) {
          otpDeliveryMessage = 'OTP sent to email';
        }
      } catch (emailErr) {
        console.error('Resend OTP email error:', emailErr.message);
        otpDeliveryMessage = 'OTP email delivery failed';
      }

      res.json({
        success: true,
        message: 'OTP resent successfully',
        userId: user._id,
        email: user.email,
        otpSent,
        otpDeliveryMessage,
        otp: process.env.NODE_ENV === 'production' && otpSent ? undefined : otpCode,
      });
    } catch (err) {
      console.error('Resend OTP error:', err.message);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  }
);

router.post(
  '/login',
  [
    body('email').trim().isEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const email = req.body.email.trim().toLowerCase();
    const { password } = req.body;

    try {
      const user = await User.findOne({ email }).select('+password');
      if (!user) {
        return res.status(401).json({ success: false, error: 'Invalid email or password' });
      }

      const passwordMatches = await bcrypt.compare(password, user.password);
      if (!passwordMatches) {
        return res.status(401).json({ success: false, error: 'Invalid email or password' });
      }

      const token = createToken(user);
      res.json(buildAuthResponse(user, token, { message: 'Login successful' }));
    } catch (err) {
      console.error('Login error:', err.message);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  }
);

module.exports = router;
