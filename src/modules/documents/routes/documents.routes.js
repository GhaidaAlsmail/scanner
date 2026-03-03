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

// --- دالة مساعدة لتنظيف الأسماء العربية والرموز ---
const sanitizeFileName = (name) => {
    return name
        .replace(/[/\\?%*:|"<>]/g, '-')
        .replace(/\s+/g, ' ')          
        .trim();
};

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
        const identifier = req.body.id || '0'; 
        const subName = req.body.subArea || 'doc'; 
        
        const titleFromFlutter = req.body.title || 'NoTitle';
        
        const safeTitle = sanitizeFileName(titleFromFlutter);
        
        cb(null, `${identifier}-${subName}-${safeTitle}.pdf`);
    }
});

// ---------------------------------------------------------------- //
const upload = multer({ storage,limits: { fileSize: 50 * 1024 * 1024 }});
//------------------------------------------------------------------------------------//

// router.get('/all', protect, async (req, res) => {
//     try {
//         const page = parseInt(req.query.page) || 1;
//         const limit = parseInt(req.query.limit) || 10;
//         const skip = (page - 1) * limit;

//         const docs = await Document.find({ user: req.user.id })
//             .sort({ createdAt: -1 }) // الأحدث أولاً
//             .skip(skip)
//             .limit(limit);

//         const totalDocs = await Document.countDocuments({ user: req.user.id });
//         const totalPages = Math.ceil(totalDocs / limit);

//         res.json({
//             docs,
//             meta: {
//                 totalDocs,
//                 totalPages,
//                 currentPage: page,
//                 hasNextPage: page < totalPages
//             }
//         });
//     } catch (err) {
//         res.status(500).json({ message: "خطأ في جلب البيانات" });
//     }
// });
//-------------------------------------------------------------------------------//
router.get('/all', protect, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const docs = await Document.find() 
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const totalDocs = await Document.countDocuments(); 
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
//--------------------------------------------------------------------------------//

router.post('/upload-pdf', protect, upload.single('pdf'), async (req, res) => {
    try {
        const { title, region, subArea, id } = req.body; 
        
        const existingDoc = await Document.findOne({ 
            title: title, 
            region: region,
            subArea: subArea,
            id: id,
            // user: req.user.id 
        });

        if (existingDoc) {
            if (req.file) fs.unlinkSync(req.file.path);
            return res.status(400).json({ message: "هذا المستند (بهذا العنوان المدمج) موجود مسبقاً" });
        }

        const newDoc = new Document({
            id: id,
            user: req.user.id,
            title: title, 
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

//-------------------------------------------------------------------------------------------//

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
//--------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
router.put('/update-pdf/:id', protect, upload.single('pdf'), async (req, res) => {
    try {
        const { id } = req.params; 
        const { title, region, subArea } = req.body;

        const document = await Document.findById(id);
        if (!document) {
             if (req.file) fs.unlinkSync(req.file.path);
             return res.status(404).json({ message: "المستند غير موجود" });
        }

        let updateData = {};
        if (title) updateData.title = title;
        if (region) updateData.region = region;
        if (subArea) updateData.subArea = subArea;

        const isDataChanged = (title && title !== document.title) || 
                             (region && region !== document.region) || 
                             (subArea && subArea !== document.subArea);

        if (req.file || isDataChanged) {
            const finalRegion = region || document.region;
            const finalSubArea = subArea || document.subArea;
            const finalTitle = title || document.title;
            const docNumericId = document.id;

            const targetDir = path.join('uploads', 'pdfs', finalRegion, finalSubArea);
            if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });

            const safeTitle = finalTitle.replace(/[/\\?%*:|"<>]/g, '-').replace(/\s+/g, ' ').trim();
            const fileName = `${docNumericId}-${finalSubArea}-${safeTitle}.pdf`;
            const finalPath = path.join(targetDir, fileName);
            const normalizedFinalPath = finalPath.replace(/\\/g, '/');

            if (req.file) {
                if (document.pdfPath && fs.existsSync(document.pdfPath)) {
                    fs.unlinkSync(document.pdfPath);
                }
                fs.renameSync(req.file.path, finalPath);
                updateData.pdfPath = normalizedFinalPath;
            } else if (isDataChanged && document.pdfPath && fs.existsSync(document.pdfPath)) {
                if (document.pdfPath !== normalizedFinalPath) {
                    fs.renameSync(document.pdfPath, finalPath);
                    updateData.pdfPath = normalizedFinalPath;
                }
            }
        }

        const updatedDoc = await Document.findByIdAndUpdate(id, updateData, { new: true });
        res.status(200).json(updatedDoc);
    } catch (error) {
        if (req.file) fs.unlinkSync(req.file.path);   
        res.status(500).json({ error: error.message });
    }
});
//------------------------------------------------------------------------------//
// راوت حذف مستند PDF

// router.delete('/:id', protect, async (req, res) => {
//     try {
//         // 1. البحث عن المستند والتأكد أنه يخص المستخدم
//         const document = await Document.findOne({ _id: req.params.id, user: req.user.id });

//         if (!document) {
//             return res.status(404).json({ message: "المستند غير موجود أو لا تملك صلاحية حذفه" });
//         }

//         // 2. حذف الملف الفيزيائي من مجلد uploads/pdfs
//         if (document.pdfPath) {
           
//             const filePath = path.join(process.cwd(), document.pdfPath);
            
//             if (fs.existsSync(filePath)) {
//                 fs.unlinkSync(filePath);
                
//             }
//         }

//         // 3. حذف السجل من قاعدة البيانات
//         await Document.findByIdAndDelete(req.params.id);

//         res.json({ message: "تم حذف المستند والملف بنجاح" });
//     } catch (err) {
//         console.error("Error deleting document:", err);
//         res.status(500).json({ message: "خطأ في السيرفر أثناء حذف المستند" });
//     }
// });
// ✅ أضف adminOnly هنا
router.delete('/:id', protect, adminOnly, async (req, res) => {
    try {
        // ✅ التعديل هنا: المدير يمكنه حذف أي مستند بغض النظر عن صاحبه
        const document = await Document.findById(req.params.id);

        if (!document) {
            return res.status(404).json({ message: "المستند غير موجود" });
        }

        // حذف الملف الفيزيائي
        if (document.pdfPath) {
            const filePath = path.join(process.cwd(), document.pdfPath);
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }
        }

        await Document.findByIdAndDelete(req.params.id);
        res.json({ message: "تم حذف المستند بنجاح بواسطة المدير" });
    } catch (err) {
        res.status(500).json({ message: "خطأ في السيرفر أثناء الحذف" });
    }
});
//------------------------------------------------------------------------------------//

//------------------------------------------------------------------------------------//
export default router;
