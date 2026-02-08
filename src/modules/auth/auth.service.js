import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../users/user.model.js';
import crypto from 'crypto';
import { sendVerificationEmail } from '../../utils/sendVerificationEmail.js';

export const register = async (userData, password) => {
  // 1. تشفير كلمة المرور
  const passwordHash = await bcrypt.hash(password, 10);
  const verificationToken = crypto.randomBytes(32).toString('hex');

  // 2. إنشاء المستخدم (تأكد من استخدام User بالكبير)
  const user = await User.create({
    ...userData,
    passwordHash,
    isVerified: false,
    emailVerificationToken: verificationToken,
    emailVerificationExpires: Date.now() + 24 * 60 * 60 * 1000, // 24 ساعة
  });

  // 3. إرسال إيميل التفعيل
  await sendVerificationEmail(user.email, verificationToken);

  return user;
};

export const login = async (email, password) => {
  const user = await User.findOne({ email }); // تصحيح الاسم إلى User
  if (!user) throw new Error('INVALID_CREDENTIALS');

  if (!user.isVerified) throw new Error('EMAIL_NOT_VERIFIED');

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new Error('INVALID_CREDENTIALS');

  // توليد التوكن
  const token = jwt.sign(
    { userId: user._id, isAdmin: user.isAdmin },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  return { user, token };
};