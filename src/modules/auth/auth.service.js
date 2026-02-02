import { sign } from 'jsonwebtoken';
import { hash as _hash, compare } from 'bcrypt';
import { create, findByEmail } from '../users/user.repository';

export async function register(email, password, userData) {
  const hash = await _hash(password, 10);

  const user = {
    ...userData,
    email,
    passwordHash: hash,
  };

  await create(user);

  // لاحقًا email verification
  return user;
}

export async function login(email, password) {
  const user = await findByEmail(email);
  if (!user) throw new Error('Invalid credentials');

  const ok = await compare(password, user.passwordHash);
  if (!ok) throw new Error('Invalid credentials');

  const token = sign(
    { userId: user.id, isAdmin: user.isAdmin },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  return { token, user };
}
