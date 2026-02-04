import { Router } from 'express';
import { login, register, forgotPassword, resendVerificationEmail, verifyEmail } from './auth.controller.js';

const router = Router();

router.post('/login', login);
router.post('/register', register);
router.post('/forgot-password', forgotPassword);
router.post('/resend-verification', resendVerificationEmail);
router.post('/verify-email', verifyEmail);

export default router;

//////////////////////////////////////////try dont delete XXXXXXX ///////////////////////////

// import { Router } from 'express';
// import { login, register, forgotPassword, resendVerificationEmail, verifyEmail } from './auth.controller.js';

// const router = Router();

// router.post('/register', register);
// router.post('/login', login);
// router.post('/forgot-password', forgotPassword);
// router.post('/resend-verification', resendVerificationEmail);
// router.post('/verify-email', verifyEmail);

// export default router;