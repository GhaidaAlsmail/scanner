// import jwt from 'jsonwebtoken';

// export const protect = async (req, res, next) => {
//   let token;

//   if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
//     try {
//       token = req.headers.authorization.split(' ')[1];
//       const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
//       // نضع معرف المستخدم في الطلب ليستخدمه الكنترولر لاحقاً
//       req.userId = decoded.userId;
//       next();
//     } catch (error) {
//       res.status(401).json({ message: 'غير مصرح لك، التوكن غير صالح' });
//     }
//   }

//   if (!token) {
//     res.status(401).json({ message: 'غير مصرح لك، لا يوجد توكن' });
//   }
// };


import jwt from 'jsonwebtoken';
import User from '../modules/users/user.model.js'; // تأكد من استيراد الموديل

export const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // بدلاً من تخزين الـ ID فقط، سنجلب المستخدم كاملاً من الداتابيز
      // نستخدم .select('-passwordHash') لكي لا نرسل الباسورد المشفر للكنترولر
      req.user = await User.findById(decoded.id || decoded.userId).select('-passwordHash');

      if (!req.user) {
        return res.status(401).json({ message: 'المستخدم غير موجود' });
      }

      next();
    } catch (error) {
      return res.status(401).json({ message: 'غير مصرح لك، التوكن غير صالح' });
    }
  }

  if (!token) {
    return res.status(401).json({ message: 'غير مصرح لك، لا يوجد توكن' });
  }
};