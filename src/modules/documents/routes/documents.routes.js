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
        // استلام المنطقة من جسم الطلب (req.body)
        const region = req.body.region || 'General'; 
        const dir = `uploads/pdfs/${region}`;

        // إنشاء المجلد إذا لم يكن موجوداً (التخزين حسب المنطقة)
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        // فك تشفير الاسم العربي لضمان حفظه بشكل صحيح على القرص
        const correctedName = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, `${correctedName}`);
    }
});
const upload = multer({ storage });
//------------------------------------------------------------------------------------//

router.get('/all', protect, async (req, res) => {
    try {
        // 1. استخراج رقم الصفحة والحد من الطلب (Query Params)
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        // 2. جلب الملفات الخاصة بالمستخدم مع الترتيب والتقسيم
        const docs = await Document.find({ user: req.user.id })
            .sort({ createdAt: -1 }) // الأحدث أولاً
            .skip(skip)
            .limit(limit);

        // 3. حساب العدد الكلي للملفات لمعرفة عدد الصفحات
        const totalDocs = await Document.countDocuments({ user: req.user.id });
        const totalPages = Math.ceil(totalDocs / limit);

        res.json({
            docs,
            meta: {
                totalDocs,
                totalPages,
                currentPage: page,
                hasNextPage: page < totalPages
            }
        });
    } catch (err) {
        res.status(500).json({ message: "خطأ في جلب البيانات" });
    }
});

//------------------------------------------------------------------------------------//

router.post('/upload-pdf', protect, upload.single('pdf'), async (req, res) => {
    try {
        const { title, region } = req.body;
        const correctedFileName = Buffer.from(req.file.originalname, 'latin1').toString('utf8');
        
        // استخدام العنوان المرسل أو اسم الملف الأصلي
        const finalTitle = title || correctedFileName;

        // 1. فحص هل الاسم موجود مسبقاً في قاعدة البيانات لنفس المنطقة؟
        const existingDoc = await Document.findOne({ 
            title: finalTitle, 
            region: region,
            user: req.user.id 
        });

        if (existingDoc) {
            // إذا وجدنا ملف بنفس الاسم، نحذف الملف الذي رفعه multer الآن لكي لا يملأ الذاكرة
            if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
            return res.status(400).json({ message: "يوجد ملف مرفوع مسبقاً بهذا الاسم في هذه المنطقة" });
        }

        const newDoc = new Document({
            user: req.user.id,
            title: finalTitle,
            region: region,
            pdfPath: req.file.path, // هنا سيكون المسار الفريد (الذي يحتوي على الأرقام)
            createdBy: req.user.id
        });

        await newDoc.save();
        res.status(201).json(newDoc);
    } catch (error) {
        // في حال حدوث خطأ، نحذف الملف المرفوع أيضاً
        if (req.file) fs.unlinkSync(req.file.path);
        res.status(500).json({ message: error.message });
    }
});
//------------------------------------------------------------------------------------//
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
                console.log(` تم حذف ملف PDF: ${filePath}`);
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

//------------------------------------------------------------------------------------//
export default router;