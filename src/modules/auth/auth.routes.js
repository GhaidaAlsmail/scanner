import { Router } from 'express';
import { login, register, forgotPassword, resendVerificationEmail, verifyEmail, getMe,resetPassword,addEmployee } from './auth.controller.js';
import { protect,adminOnly } from '../../middleware/auth.middleware.js';

const router = Router();

router.post('/login', login);
router.post('/register', register);
router.post('/forgot-password', forgotPassword);
router.post('/resend-verification', resendVerificationEmail);
router.get('/verify-email/:token', verifyEmail);
router.get('/me', protect, getMe);
router.patch('/reset-password/:token', resetPassword);
router.post('/add-employee', protect, adminOnly, addEmployee);
export default router;

