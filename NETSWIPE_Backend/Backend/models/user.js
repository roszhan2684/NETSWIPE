const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    username: {
      type: String,
      trim: true,
      unique: true,
      sparse: true,
    },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, select: false },
    domain: String,
    bio: { type: String, default: '' },
    description: { type: String, default: '' },
    profilePhoto: { type: String, default: '' },
    location: { type: String, default: '' },
    isProfileComplete: { type: Boolean, default: false },
    profileCompleted: { type: Boolean, default: false },
    isVerified: { type: Boolean, default: false },
    otpCode: { type: String, select: false, default: null },
    otpExpires: { type: Date, select: false, default: null },
    skills: { type: [String], default: [] },
    interests: { type: [String], default: [] },
  },
  { timestamps: true }
);

userSchema.set('toJSON', {
  transform: (_doc, ret) => {
    ret.id = ret._id.toString();
    ret.bio = ret.bio || ret.description || '';
    ret.description = ret.description || ret.bio || '';
    ret.isProfileComplete = Boolean(ret.isProfileComplete || ret.profileCompleted);
    ret.profileCompleted = Boolean(ret.profileCompleted || ret.isProfileComplete);
    delete ret.password;
    delete ret.otpCode;
    delete ret.otpExpires;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
