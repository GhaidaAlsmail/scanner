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

export const protect = async (req, res, next) => {
  let token;

  // التأكد من وجود التوكن في الـ Headers
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      // التحقق من صحة التوكن باستخدام المفتاح السري الموجود في .env
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // إضافة معرف المستخدم للطلب ليستخدمه الكنترولر لاحقاً
      req.userId = decoded.userId;
      next();
    } catch (error) {
      res.status(401).json({ message: 'غير مصرح لك، التوكن غير صالح' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'غير مصرح لك، لا يوجد توكن' });
  }
};