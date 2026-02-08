
import * as authService from './auth.service.js';
import crypto from 'crypto';
import User from '../users/user.model.js';
import { sendVerificationEmail } from '../../utils/sendVerificationEmail.js';

export const register = async (req, res) => {
  const { password, ...userData } = req.body;
  const user = await authService.register(userData, password);
  res.json(user);
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  } catch (e) {
    res.status(401).json({
      message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    });
  }
};

export const forgotPassword = async (req, res) => {
  res.json({
    message: 'إذا كان البريد موجود سيتم إرسال رسالة',
  });
};


export const resendVerificationEmail = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const user = await User.findOne({ email });

    if (!user) {
      // رسالة عامة للأمان
      return res.status(200).json({
        message: 'If email exists, verification email will be sent',
      });
    }

    if (user.isVerified) {
      return res.status(400).json({
        message: 'Email already verified',
      });
    }

    // توليد توكن جديد
    const verificationToken = crypto.randomBytes(32).toString('hex');

    user.emailVerificationToken = verificationToken;
    user.emailVerificationExpires = Date.now() + 10 * 60 * 1000;
    await user.save();

    await sendVerificationEmail(user.email, verificationToken);

    res.status(200).json({
      message: 'Verification email resent successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const verifyEmail = async (req, res, next) => {
  try {
    // استخراج التوكن من الرابط
    const { token } = req.params; 

    const user = await User.findOne({
      emailVerificationToken: token,
      emailVerificationExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    // تحديث حالة المستخدم
    user.isVerified = true;
    user.emailVerificationToken = undefined;
    user.emailVerificationExpires = undefined;
    await user.save();

    // تصحيح المتغير هنا من verificationToken إلى token
    console.log("Verified successfully with token: ", token);

    res.status(200).json({ message: 'Email verified successfully' });
  } catch (error) {
    next(error);
  }
};

// في ملف src/modules/auth/auth.controller.js

export const getMe = async (req, res) => {
  try {
    // req.user تم وضعه بواسطة الـ middleware
    res.status(200).json({
      status: 'success',
      data: {
        user: req.user // هنا ستظهر البيانات كاملة
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// // ===== FORGOT PASSWORD =====
// export const forgotPassword = async (req, res, next) => {
//   try {
//     // لاحقًا: توليد token + إرسال إيميل
//     res.json({
//       message: 'إذا كان البريد موجود سيتم إرسال رسالة',
//     });
//   } catch (error) {
//     next(error);
//   }
// };

// // ===== RESEND VERIFICATION EMAIL =====
// export const resendVerificationEmail = async (req, res, next) => {
//   try {
//     const { email } = req.body;

//     if (!email) {
//       return res.status(400).json({ message: 'Email is required' });
//     }

//     const user = await User.findOne({ email });

//     if (!user) {
//       return res.status(200).json({
//         message: 'If email exists, verification email will be sent',
//       });
//     }

//     if (user.isVerified) {
//       return res.status(400).json({
//         message: 'Email already verified',
//       });
//     }

//     const verificationToken = crypto.randomBytes(32).toString('hex');

//     user.emailVerificationToken = verificationToken;
//     user.emailVerificationExpires = Date.now() + 10 * 60 * 1000; // 10 دقائق
//     await user.save();

//     await sendVerificationEmail(user.email, verificationToken);

//     res.status(200).json({
//       message: 'Verification email resent successfully',
//     });
//   } catch (error) {
//     next(error);
//   }
// };

