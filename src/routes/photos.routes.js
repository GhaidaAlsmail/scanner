// import express from 'express';
// const router = express.Router();

// import {protect} from '../middleware/auth.middleware.js'; 
// import upload from '../utils/upload.js'; 
// import Photo from '../modules/photos/photos.js'; 

// router.post('/add-photo', protect, upload.single('image'), async (req, res) => {
//   try {
//     // 1. التأكد من وجود ملف
//     if (!req.file) {
//       return res.status(400).json({ message: 'الرجاء اختيار ملف صورة.' });
//     }

//     // 2. استخراج البيانات (مع وضع قيم افتراضية لتجنب الـ null)
//     const { head, name, details } = req.body;

//     if (!head || !name) {
//        return res.status(400).json({ message: 'العنوان واسم الموظف مطلوبان.' });
//     }

//     // 3. الحفظ في قاعدة البيانات
//     // const photo = await Photo.create({
//     //   user: req.user.id || req.user._id, // تأمين الحصول على الـ ID بكلا الشكلين
//     //   head: head,
//     //   name: name,
//     //   details: details,
//     //   // تأكدي أن هذا المسار هو ما تريدينه فعلاً للوصول للصورة من المتصفح
//     //   path: req.file.path.replace(/\\/g, "/"), 
//     //   filename: req.file.filename,
//     // });
//     // ✅ الحل الصحيح لحفظ المسار في قاعدة البيانات
//     const photo = await Photo.create({
//       user: req.user.id,
//       head: req.body.head,
//       name: req.body.name,
//       details: req.body.details,
//       // بدلاً من حفظ req.file.path الكامل، سنحفظ فقط الجزء الذي نحتاجه
//       path: `/uploads/${req.user.id}/${req.file.filename}`, 
//       filename: req.file.filename,
//     });

//     res.status(201).json({ 
//       status: 'success', 
//       message: 'تم حفظ الصورة والبيانات بنجاح',
//       data: photo 
//     });

//   } catch (error) {
//     console.error("Server Error:", error); // مهم جداً لرؤية الخطأ في Console السيرفر
//     res.status(500).json({ 
//       message: 'خطأ في السيرفر أثناء الحفظ', 
//       error: error.message 
//     });
//   }
// });


// router.get('/all', protect, async (req, res) => {
//   try {
//     // جلب الصور الخاصة بالمستخدم المسجل فقط
//     const photos = await Photo.find({ user: req.user.id }); 
    
//     res.status(200).json({
//       status: 'success',
//       photos: photos // تأكدي أن الاسم هنا "photos" ليطابق الموديل في فلاتر
//     });
//   } catch (error) {
//     res.status(500).json({ message: 'خطأ في جلب الصور', error: error.message });
//   }
// });
// export default router;
import express from 'express';
const router = express.Router();
import { protect } from '../middleware/auth.middleware.js'; 
import upload from '../utils/upload.js'; 
import Photo from '../modules/photos/photos.js'; 

// ✅ 1. إضافة صورة جديدة
router.post('/add-photo', protect, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'الرجاء اختيار ملف صورة.' });
    }

    const { head, name, details } = req.body;

    // حفظ المسار النسبي فقط (Relative Path) لتجنب مشكلة C:/Users
    const photo = await Photo.create({
      user: req.user.id,
      head: head,
      name: name,
      details: details,
      // نخزن المسار بحيث يبدأ بـ /uploads ليتمكن السيرفر من قراءته
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

// ✅ 2. جلب كل الصور للمستخدم الحالي
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

export default router;