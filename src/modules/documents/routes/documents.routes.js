import { Router } from 'express';
import multer, { diskStorage } from 'multer';
import Document from '../models/document.js'; 
import { protect,adminOnly } from '../../../middleware/auth.middleware.js';
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
        
        const region = req.body.region || 'عام'; 
        const subArea = req.body.subArea || 'غير_مصنف';

        const dir = path.join('uploads', 'pdfs', region, subArea);

        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const identifier = req.body.id || ''; 
        const subName = req.body.subArea || 'doc'; 
        const correctedName = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, `${identifier}-${subName}-${correctedName}`);
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
        const { title, region, subArea,id } = req.body; 
        const correctedFileName = Buffer.from(req.file.originalname, 'latin1').toString('utf8');
        const finalTitle = title || correctedFileName;

        const existingDoc = await Document.findOne({ 
            title: finalTitle, 
            region: region,
            subArea: subArea,
            id: id, 
            user: req.user.id 
        });

        if (existingDoc) {
            if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
            return res.status(400).json({ message: "يوجد ملف مرفوع مسبقاً بهذا الاسم في هذه المنطقة" });
        }

        const newDoc = new Document({
            id: id.toString(),
            user: req.user.id,
            title: finalTitle,
            region: region,
            subArea: subArea,
            pdfPath: req.file.path.replace(/\\/g, '/'), 
            createdBy: req.user.id
        });

        await newDoc.save();
        res.status(201).json(newDoc);
    } catch (error) {
        if (req.file) fs.unlinkSync(req.file.path);
        res.status(500).json({ message: error.message });
    }
});
//------------------------------------------------------------------------------------//


router.put('/update-title/:id', protect, async (req, res) => {
    try {
        const { title } = req.body;
        const document = await Document.findByIdAndUpdate(
            req.params.id, 
            { title }, 
            { new: true }
        );
        res.json(document);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});



//--------------------------------------------------------------------------------------//

// router.put('/update-pdf/:id', protect, upload.single('pdf'), async (req, res) => {
//     try {
//         const { id } = req.params;
//         const { title, region, subArea } = req.body;

//         const document = await Document.findById(id);
//         if (!document) return res.status(404).json({ message: "المستند غير موجود" });

//         let updateData = { title };
//         if (region) updateData.region = region;
//         if (subArea) updateData.subArea = subArea; // تحديث المنطقة الفرعية

//         if (req.file) {
//             // حذف القديم
//             if (document.pdfPath && fs.existsSync(document.pdfPath)) {
//                 fs.unlinkSync(document.pdfPath);
//             }
//             updateData.pdfPath = req.file.path.replace(/\\/g, '/');
//         }

//         const updatedDoc = await Document.findByIdAndUpdate(id, updateData, { new: true });
//         res.status(200).json(updatedDoc);
//     } catch (error) {
//         res.status(500).json({ error: error.message });
//     }
// });

// routes/pdf.js

router.put('/update-pdf/:id', protect, upload.single('pdf'), async (req, res) => {
    try {
        const { id } = req.params;
        const { title, region, subArea } = req.body;

        const document = await Document.findById(id);
        if (!document) return res.status(404).json({ message: "المستند غير موجود" });

        // البيانات الجديدة التي سيتم تحديثها
        let updateData = { title };
        if (region) updateData.region = region;
        if (subArea) updateData.subArea = subArea;

        // إذا قام المستخدم برفع ملف PDF جديد (المجمع من الصور في Flutter)
        if (req.file) {
            // 1. حذف الملف القديم فيزيائياً من السيرفر
            if (document.pdfPath && fs.existsSync(document.pdfPath)) {
                try {
                    fs.unlinkSync(document.pdfPath);
                } catch (err) {
                    console.log("المنظف: تعذر حذف الملف القديم أو أنه غير موجود");
                }
            }

            // 2. تحديد المسار الجديد بناءً على المنطقة والمنطقة الفرعية الحالية
            // ملاحظة: multer وضع الملف في مكان مؤقت، سننقله للمكان الصحيح
            const finalRegion = region || document.region;
            const finalSubArea = subArea || document.subArea;
            
            const targetDir = path.join('uploads', 'pdfs', finalRegion, finalSubArea);
            
            if (!fs.existsSync(targetDir)) {
                fs.mkdirSync(targetDir, { recursive: true });
            }

            const fileName = `${Date.now()}-${req.file.originalname}`;
            const finalPath = path.join(targetDir, fileName);

            // نقل الملف من مكان multer المؤقت إلى المجلد المنظم
            fs.renameSync(req.file.path, finalPath);

            // تحديث المسار في قاعدة البيانات (مع توحيد الميول لـ /)
            updateData.pdfPath = finalPath.replace(/\\/g, '/');
        }

        const updatedDoc = await Document.findByIdAndUpdate(id, updateData, { new: true });
        res.status(200).json(updatedDoc);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
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
           
            const filePath = path.join(process.cwd(), document.pdfPath);
            
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
                
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

//------------------------------------------------------------------------------------//
export default router;
