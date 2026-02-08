import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

// 1. تعريف __dirname لهذا الملف تحديداً
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // 2. استخدام المعرف الخاص بالمستخدم لإنشاء مجلد
    // تأكدي من استخدام id أو _id حسب ما قمتِ بتعريفه في الموديل
    const userId = req.user ? req.user._id.toString() : 'anonymous';
    
    // 3. تحديد المسار: نخرج من utils ثم نذهب لـ uploads
    const uploadPath = path.join(__dirname, '../../uploads', userId);

    // 4. إنشاء المجلد إذا لم يكن موجوداً
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    // اسم ملف فريد: الوقت الحالي + الامتداد الأصلي
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('الرجاء رفع ملف صورة فقط.'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 1024 * 1024 * 5 } // 5MB
});

export default upload;