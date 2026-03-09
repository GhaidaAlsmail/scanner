
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, unique: true, sparse: true, trim: true ,default: undefined},
    username: { type: String, required: true, unique: true },
    city: { type: String, required: true },
    notes: String,
    phone: String,
    birthDate: Date,
    profilePictureUrl: String,
    passwordResetToken: String,
    passwordResetExpires: Date,
    nickNames: [String],
    isAdmin: { type: Boolean, default: false },
    passwordHash: { type: String, required: true },
    isVerified: { type: Boolean, default: true },
    emailVerificationToken: String,
    emailVerificationExpires: Date,
  },
  { timestamps: true }
);

export default mongoose.model('User', userSchema);
