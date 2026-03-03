import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../users/user.model.js';
import crypto from 'crypto';
import { sendVerificationEmail } from '../../utils/sendVerificationEmail.js';

export const register = async (userData, password) => {
  const passwordHash = await bcrypt.hash(password, 10);
  const verificationToken = crypto.randomBytes(32).toString('hex');

  const user = await User.create({
    ...userData,
    passwordHash,
    isVerified: false,
    emailVerificationToken: verificationToken,
    emailVerificationExpires: Date.now() + 24 * 60 * 60 * 1000,
  });

  // 3. إرسال إيميل التفعيل
  await sendVerificationEmail(user.email, verificationToken);

  return user;
};




export const login = async (username, password) => {
  const user = await User.findOne({ username }); 
  if (!user) throw new Error('INVALID_CREDENTIALS');
// if (!user.isVerified && user.role !== 'admin') {
//     throw new Error('يرجى توثيق الحساب أولاً');
// }
if (!user.isVerified && !user.isAdmin) {
      throw new Error('يرجى توثيق الحساب أولاً');
  }
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new Error('INVALID_CREDENTIALS');

const token = jwt.sign(
  { id: user._id, role: user.role }, 
  process.env.JWT_SECRET,
  { expiresIn: '30d' } 
);
  return { user, token };
};