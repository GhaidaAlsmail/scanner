// import { Router } from 'express';
// import { protect } from '../../middlewares/auth.middleware.js';
// import User from '../../models/user.model.js';

// const router = Router();

// // مسار الحصول على بياناتي (يستخدمه Flutter عند فتح التطبيق)
// router.get('/me', protect, async (req, res) => {
//   try {
//     const user = await User.findById(req.userId).select('-passwordHash');
//     res.json(user);
//   } catch (error) {
//     res.status(500).json({ message: 'خطأ في السيرفر' });
//   }
// });

// export default router;

import { Router } from 'express';
import { protect } from '../../middlewares/auth.middleware.js';
import User from './user.model.js';

const router = Router();

/**
 * @route   GET /api/users/me
 * @desc    الحصول على بيانات المستخدم الحالي (يستخدمها Flutter)
 * @access  Private
 */
router.get('/me', protect, async (req, res, next) => {
  try {
    // req.userId يأتي من ميدل وير protect
    const user = await User.findById(req.userId).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ message: 'المستخدم غير موجود' });
    }

    res.json(user);
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/users/me
 * @desc    تحديث بيانات البروفايل
 */
router.put('/me', protect, async (req, res, next) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.userId,
      { $set: req.body },
      { new: true, runValidators: true }
    ).select('-passwordHash');

    res.json(updatedUser);
  } catch (error) {
    next(error);
  }
});

export default router;