
import crypto from 'crypto';
import { sendVerificationEmail } from '../utils/sendVerificationEmail.js';

export const register = async (userData, password) => {
  const passwordHash = await bcrypt.hash(password, 10);

  const verificationToken = crypto.randomBytes(32).toString('hex');

  const user = await user.create({
    ...userData,
    passwordHash,
    isVerified: false,
    emailVerificationToken: verificationToken,
    emailVerificationExpires: Date.now() + 10 * 60 * 1000, // 10 دقائق
  });

  await sendVerificationEmail(user.email, verificationToken);

  return user;
};

export const login = async (email, password) => {
  const user = await user.findOne({ email });
  if (!user) {
    throw new Error('INVALID_CREDENTIALS');
  }

  if (!user.isVerified) {
    throw new Error('EMAIL_NOT_VERIFIED');
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    throw new Error('INVALID_CREDENTIALS');
  }

  const token = jwt.sign(
    {
      userId: user._id,
      isAdmin: user.isAdmin,
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  return {
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      isAdmin: user.isAdmin,
      stars: user.stars,
    },
  };
};