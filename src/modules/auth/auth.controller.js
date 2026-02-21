
import * as authService from './auth.service.js';
import crypto from 'crypto';
import bcrypt from 'bcrypt';
import User from '../users/user.model.js';
import { sendVerificationEmail } from '../../utils/sendVerificationEmail.js';
import nodemailer from 'nodemailer';

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


// داخل auth.controller.js
export const forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(200).json({ message: 'إذا كان البريد موجود سيتم إرسال رسالة' });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    
    user.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    user.passwordResetExpires = Date.now() + 20 * 60 * 1000; 

    await user.save({ validateBeforeSave: false });

    // --- التعديل هنا لجعل الرابط ديناميكياً ---
    // req.get('host') تجلب الـ IP والـ Port تلقائياً (مثلاً 192.168.1.5:3006)
    // req.protocol تجلب http أو https تلقائياً
    const host = req.get('host');
    const protocol = req.protocol;
    const resetURL = `${protocol}://${host}/reset-password/${resetToken}`;
    
    const message = `نسيت كلمة المرور؟ قم بزيارة الرابط التالي لتغييرها: \n\n ${resetURL}`;
    // ------------------------------------------

    const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS,
        },
    });

    await transporter.sendMail({
        from: `"Scanner App" <${process.env.EMAIL_USER}>`, // قمت بتغيير الاسم لـ Scanner App
        to: user.email,
        subject: 'رابط إعادة تعيين كلمة المرور',
        text: message,
    });

    res.status(200).json({ status: 'success', message: 'تم إرسال الرابط بنجاح' });

  } catch (error) {
    console.log("Error in forgotPassword:", error); 
    res.status(500).json({ message: 'خطأ في السيرفر' });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const hashedToken = crypto.createHash('sha256').update(req.params.token).digest('hex');

    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
    });

    if (!user) {
        return res.status(400).json({ message: 'التوكن غير صالح أو انتهت صلاحيته' });
    }


    //  تشفير كلمة المرور الجديدة قبل حفظها
    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(req.body.password, salt);
    
    // تنظيف توكنات إعادة التعيين
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    
    await user.save({ validateBeforeSave: false });

    res.status(200).json({ message: 'تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'خطأ في السيرفر' });
  }
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


export const getMe = async (req, res) => {
  try {
    // req.user تم وضعه بواسطة الـ middleware
    res.status(200).json({
      status: 'success',
      data: {
        user: req.user 
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};