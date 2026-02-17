import express from 'express';
const router = express.Router();
import { protect } from '../middleware/auth.middleware.js'; 
import upload from '../utils/upload.js'; 
import Photo from '../modules/photos/photos.js'; 
import fs from 'fs';
import path from 'path';
//----------------------------------------------------------------------------//
//  1. إضافة صورة جديدة
router.post('/add-photo', protect, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'الرجاء اختيار ملف صورة.' });
    }

    const { head, name, details } = req.body;

    const photo = await Photo.create({
      user: req.user.id,
      head: head,
      name: name,
      details: details,
      path: `/uploads/${req.user.id}/${req.file.filename}`, 
      filename: req.file.filename,
    });

    res.status(201).json({ 
      status: 'success', 
      message: 'تم حفظ الصورة والبيانات بنجاح',
      data: photo 
    });

  } catch (error) {
    console.error("Server Error:", error);
    res.status(500).json({ 
      message: 'خطأ في السيرفر أثناء الحفظ', 
      error: error.message 
    });
  }
});
//----------------------------------------------------------------------------//
//  2. جلب كل الصور للمستخدم الحالي
router.get('/all', protect, async (req, res) => {
  try {
    const photos = await Photo.find({ user: req.user.id }); 
    res.status(200).json({
      status: 'success',
      photos: photos 
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في جلب الصور', error: error.message });
  }
});

//----------------------------------------------------------------------------//
router.delete('/:id', protect, async (req, res) => {
    try {
        const photo = await Photo.findById(req.params.id); 

        if (!photo) {
            return res.status(404).json({ message: "الصورة غير موجودة" });
        }

        if (photo.path) {
            const filePath = path.join(process.cwd(), photo.path);
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }
        }

        await Photo.findByIdAndDelete(req.params.id);

        res.json({ message: "تم حذف الصورة والملف بنجاح" });
    } catch (err) {
        console.error("Error deleting photo:", err);
        res.status(500).json({ message: "خطأ في السيرفر" });
    }
});


export default router;