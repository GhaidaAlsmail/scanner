import { Router } from 'express';
import multer, { diskStorage } from 'multer';
import Document from '../models/document.js'; 
import { protect } from '../../../middleware/auth.middleware.js';
import fs from 'fs';
import path from 'path';

const router = Router();

// التأكد من وجود المجلدات عند تشغيل السيرفر
const uploadDir = path.join(process.cwd(), 'uploads/pdfs');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/pdfs/'); // تأكدي أن هذا المجلد موجود يدوياً أو برمجياً
    },
    filename: (req, file, cb) => {
        // إضافة timestamp لتجنب تكرار الأسماء
        // const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null,  file.originalname); 
    }
});
// const storage = diskStorage({
//     destination: './uploads/pdfs/',
//     filename: (req, file, cb) => {
//         cb(null, file.originalname); 
//     }
// });
const upload = multer({ storage });

router.post('/upload-pdf', protect, upload.single('pdf'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: "No file uploaded" });

        const newPdf = new Document({
            user: req.user.id,
            pdfPath: `/uploads/pdfs/${req.file.filename}`,
            title: req.body.title || "Document"
        });
        await newPdf.save();
        res.status(201).json(newPdf);
    } catch (error) {
        res.status(500).json({ message: "Error saving PDF" });
    }
});

// راوت جلب كل مستندات المستخدم
router.get('/all', protect, async (req, res) => {
    try {
        const docs = await Document.find({ user: req.user.id }).sort({ createdAt: -1 });
        res.json(docs);
    } catch (err) {
        res.status(500).json({ message: "خطأ في جلب البيانات" });
    }
});

// 2. جلب كل الصور للمستخدم الحالي
router.get('/all', protect, async (req, res) => {
  try {
     const photos = await Photo.find({ user: req.user.id }).lean(); 
    
    res.status(200).json({
      status: 'success',
      photos: photos 
    });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في جلب الصور', error: error.message });
  }
});



// راوت حذف مستند PDF
router.delete('/:id', protect, async (req, res) => {
    try {
        // 1. البحث عن المستند والتأكد أنه يخص المستخدم
        const document = await Document.findOne({ _id: req.params.id, user: req.user.id });

        if (!document) {
            return res.status(404).json({ message: "المستند غير موجود أو لا تملك صلاحية حذفه" });
        }

        // 2. حذف الملف الفيزيائي من مجلد uploads/pdfs
        if (document.pdfPath) {
            // نستخدم path.join للوصول للمسار الصحيح بناءً على مكان تشغيل السيرفر
            const filePath = path.join(process.cwd(), document.pdfPath);
            
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
                console.log(`✅ تم حذف ملف PDF: ${filePath}`);
            }
        }

        // 3. حذف السجل من قاعدة البيانات
        await Document.findByIdAndDelete(req.params.id);

        res.json({ message: "تم حذف المستند والملف بنجاح" });
    } catch (err) {
        console.error("Error deleting document:", err);
        res.status(500).json({ message: "خطأ في السيرفر أثناء حذف المستند" });
    }
});
export default router;