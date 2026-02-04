
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    city: String,
    notes: String,
    phone: String,
    birthDate: Date,
    profilePictureUrl: String,
    nickNames: [String],
    isAdmin: { type: Boolean, default: false },
    stars: { type: Number, default: 0 },
    passwordHash: { type: String, required: true },
    isVerified: { type: Boolean, default: false },
    emailVerificationToken: String,
    emailVerificationExpires: Date,
  },
  { timestamps: true }
);

export default mongoose.model('User', userSchema);
