// models/message.js
const mongoose = require('mongoose');
const { createChatId } = require('../utils/chat');

const messageSchema = new mongoose.Schema(
  {
    chatId: { type: String, index: true },
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    text: { type: String, required: true },
  },
  { timestamps: true }
);

messageSchema.pre('validate', function syncMessageFields(next) {
  if (!this.fromUserId && this.sender) {
    this.fromUserId = this.sender;
  }

  if (!this.toUserId && this.receiver) {
    this.toUserId = this.receiver;
  }

  if (!this.sender && this.fromUserId) {
    this.sender = this.fromUserId;
  }

  if (!this.receiver && this.toUserId) {
    this.receiver = this.toUserId;
  }

  if (!this.chatId && this.fromUserId && this.toUserId) {
    this.chatId = createChatId(this.fromUserId, this.toUserId);
  }

  next();
});

messageSchema.set('toJSON', {
  transform: (_doc, ret) => {
    ret.id = ret._id.toString();
    if (!ret.fromUserId && ret.sender) {
      ret.fromUserId = ret.sender;
    }
    if (!ret.toUserId && ret.receiver) {
      ret.toUserId = ret.receiver;
    }
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Message', messageSchema);
