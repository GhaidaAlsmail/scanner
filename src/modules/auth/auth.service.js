import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../users/user.model.js';

export const login = async (email, password) => {
  const user = await User.findOne({ email });
  if (!user) {
    throw new Error('INVALID_CREDENTIALS');
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

export const register = async (userData, password) => {
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ ...userData, passwordHash }); 
  return user;
};