// models/swipe.js
const mongoose = require('mongoose');

const swipeSchema = new mongoose.Schema({
  swiper: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  swipedOn: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  direction: { type: String, enum: ['left', 'right'], required: true },
}, { timestamps: true });

module.exports = mongoose.model('Swipe', swipeSchema);
