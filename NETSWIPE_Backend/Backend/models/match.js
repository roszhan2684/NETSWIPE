// models/match.js
const mongoose = require('mongoose');

const matchSchema = new mongoose.Schema({
  users: {
    type: [mongoose.Schema.Types.ObjectId],
    required: true,
    validate: v => v.length === 2,
    ref: 'User'
  },
  matchedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('Match', matchSchema);
