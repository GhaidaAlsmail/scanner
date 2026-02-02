import { register, login } from './auth.service';

export async function register(req, res) {
  const { email, password, name } = req.body;

  const user = await register(email, password, {
    id: crypto.randomUUID(),
    name,
    isAdmin: false,
    stars: 0,
  });

  res.json(user);
}

export async function login(req, res) {
  const { email, password } = req.body;
  const result = await login(email, password);
  res.json(result);
}
