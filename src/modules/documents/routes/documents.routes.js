import { Router } from 'express';
import multer, { diskStorage } from 'multer';
import Document from '../models/document.js'; 
import { protect } from '../../../middleware/auth.middleware.js';

const router = Router();

const storage = diskStorage({
    destination: './uploads/pdfs/',
    filename: (req, file, cb) => {
        cb(null, file.originalname); 
    }
});
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



// راوت حذف مستند معين
router.delete('/:id', protect, async (req, res) => {
    try {
        // 1. البحث عن المستند والتأكد أنه يخص المستخدم الحالي
        const document = await Document.findOne({ _id: req.params.id, user: req.user.id });

        if (!document) {
            return res.status(404).json({ message: "المستند غير موجود أو لا تملك صلاحية حذفه" });
        }

        // 2. حذف المستند من قاعدة البيانات
        await Document.findByIdAndDelete(req.params.id);

        res.json({ message: "تم حذف المستند بنجاح" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "خطأ في السيرفر أثناء الحذف" });
    }
});

export default router;