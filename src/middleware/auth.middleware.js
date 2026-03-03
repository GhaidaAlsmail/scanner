import jwt from 'jsonwebtoken';
import User from '../modules/users/user.model.js';

export const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

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

//----------------------------------------------------------------------------//

export const adminOnly = (req, res, next) => {
    if (req.user && req.user.isAdmin) {
        next(); 
    } else {
        res.status(403).json({ message: "خطأ: هذه الصلاحية للمدير فقط!" });
    }
};