import { Router } from 'express';
import { login } from './auth.controller.js';

const router = Router();

router.post('/login', login);
router.post('/forgot-password', forgotPassword);
// import { forgotPassword } from './auth.controller.js';
router.post('/resend-verification', (req, res) => {
  res.json({ message: 'تم إرسال بريد التحقق' });
});

// router.post('/verify-email', (req, res) => {
//   res.json({ message: 'تم التحقق من البريد' });
// });

// router.post('/register', register);

export default router;
