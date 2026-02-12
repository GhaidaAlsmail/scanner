import express from 'express';
const router = express.Router();

// استيراد الميدل ويرز (تأكدي من صحة المسارات واللاحقة .js)
import {protect} from '../middleware/auth.middleware.js'; 
import upload from '../utils/upload.js'; 

// استيراد الموديل (بدون أقواس {} لأننا استخدمنا export default)
import Photo from '../modules/photos/photos.js'; 

// المسار: POST /api/photos/upload
router.post('/upload', protect, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'الرجاء اختيار ملف صورة.' });
    }

    // نستخدم Photo.create وليس create مباشرة
    const photo = await Photo.create({
      user: req.user.id,
      path: `/uploads/${req.user.id}/${req.file.filename}`,
      filename: req.file.filename,
      mimetype: req.file.mimetype,
      size: req.file.size,
    });

    res.status(201).json({ status: 'success', data: { photo } });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في الرفع', error: error.message });
  }
});

export default router;