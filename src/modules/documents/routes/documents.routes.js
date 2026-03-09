import { Router } from 'express';
import multer, { diskStorage } from 'multer';
import Document from '../models/document.js'; 
import { protect,adminOnly } from '../../../middleware/auth.middleware.js';
import fs from 'fs';
import path from 'path';
import imagesToPdf from 'images-to-pdf';

const router = Router();
const ensureExists = (dir) => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
};

// 2. إعداد المسارات الأساسية
const tempUploadPath = path.join(process.cwd(), 'uploads/temp');
ensureExists(tempUploadPath);
ensureExists(path.join(process.cwd(), 'uploads/pdfs'));

// 3. إعداد Multer خاص للصور المتعددة (الرفع المؤقت)
const imageStorage = diskStorage({
    destination: (req, file, cb) => {
        ensureExists(tempUploadPath);
        cb(null, tempUploadPath);
    },
    filename: (req, file, cb) => {
        const safeName = file.originalname.replace(/\s+/g, '_').replace(/[/\\?%*:|"<>]/g, '');
        cb(null, `${Date.now()}-${safeName}`);
    }
});

const uploadImages = multer({ 
    storage: imageStorage,
    limits: { fileSize: 30 * 1024 * 1024 } // 30MB للصورة الواحدة
});

// التأكد من وجود المجلدات عند تشغيل السيرفر
const uploadDir = path.join(process.cwd(), 'uploads/pdfs');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}


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

// ----------------------------------------------------------------------------------
//  الراوت الجديد: تحويل الصور المرفوعة من Flutter إلى PDF واحد وحفظه في القاعدة
// ----------------------------------------------------------------------------------
router.post('/upload-images-to-pdf', protect, uploadImages.array('images', 50), async (req, res) => {
    try {
        const { title, region, subArea, id } = req.body;
        const files = req.files;

        if (!files || files.length === 0) {
            return res.status(400).json({ message: "لم يتم اختيار صور" });
        }

        // أ. تحديد مسار الحفظ النهائي (حسب المنطقة والمنطقة الفرعية)
        const safeTitle = title.replace(/[/\\?%*:|"<>]/g, '-').replace(/\s+/g, '_').trim();
        const fileName = `${id}-${subArea}-${safeTitle}-${Date.now()}.pdf`;
        const targetDir = path.join('uploads', 'pdfs', region || 'عام', subArea || 'غير_مصنف');
        
        ensureExists(targetDir);
        const finalPdfPath = path.join(targetDir, fileName);
        const normalizedPath = finalPdfPath.replace(/\\/g, '/');

        // ب. تجميع مسارات الصور المؤقتة
        const imagePaths = files.map(file => file.path);

        // ج. تحويل الصور إلى PDF واحد (الجودة الأصلية)
        await imagesToPdf(imagePaths, finalPdfPath);

        // د. حذف الصور المؤقتة فوراً لتوفير مساحة السيرفر
        imagePaths.forEach(imgPath => {
            if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
        });

        // هـ. حفظ البيانات في قاعدة البيانات
        const newDoc = new Document({
            id: id,
            user: req.user.id,
            title: title,
            region: region,
            subArea: subArea,
            pdfPath: normalizedPath,
            createdBy: req.user.id
        });

        await newDoc.save();

        res.status(201).json({
            success: true,
            message: "تم إنشاء المستند وحذف الصور الأصلية بنجاح",
            doc: newDoc
        });

    } catch (error) {
        // تنظيف في حال الخطأ
        if (req.files) {
            req.files.forEach(f => { if (fs.existsSync(f.path)) fs.unlinkSync(f.path); });
        }
        console.error("PDF Creation Error:", error);
        res.status(500).json({ message: "خطأ في معالجة الصور وتحويلها لـ PDF" });
    }
});
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
//------------------------------------راوت الرفع بدون ضغط--------------------------------------------//

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


export const uploadAndCreatePdf = async (req, res) => {
    try {
        const { title, region, subArea, id } = req.body;
        const files = req.files; // الصور المرفوعة عبر multer

        if (!files || files.length === 0) {
            return res.status(400).json({ message: "لم يتم اختيار صور" });
        }

        // 1. تحديد مسار الحفظ النهائي للـ PDF
        const fileName = `${Date.now()}_${title}.pdf`;
        const dirPath = path.join('uploads', 'pdfs', region, subArea);
        
        // إنشاء المجلد إذا لم يكن موجوداً
        if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
        
        const finalPdfPath = path.join(dirPath, fileName);

        // 2. تجميع مسارات الصور المؤقتة التي رفعها multer
        const imagePaths = files.map(file => file.path);

        // 3. تحويل الصور إلى PDF (يحافظ على الدقة الأصلية الكاملة)
        await imagesToPdf(imagePaths, finalPdfPath);

        // 4. 🔥 الحل السحري: حذف الصور الأصلية فوراً لتوفير المساحة
        imagePaths.forEach(imgPath => {
            if (fs.existsSync(imgPath)) {
                fs.unlinkSync(imgPath); 
            }
        });

        // 5. حفظ بيانات المستند في قاعدة البيانات (مثال)
        // const newDoc = await Document.create({ title, region, subArea, userId: id, pdfUrl: finalPdfPath });

        res.status(201).json({
            success: true,
            message: "تم إنشاء المستند وحذف الصور المؤقتة بنجاح",
            path: finalPdfPath
        });

    } catch (error) {
        console.error("Error in PDF Creation:", error);
        res.status(500).json({ message: "خطأ في معالجة الصور على السيرفر" });
    }
};
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

router.delete('/:id', protect, adminOnly, async (req, res) => {
    try {
        //  التعديل هنا: المدير يمكنه حذف أي مستند بغض النظر عن صاحبه
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
