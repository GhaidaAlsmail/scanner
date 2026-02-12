import upload from '../utils/upload.js'; // ملف Multer الذي جهزناه
import { Photo } from '../models/photo.model.js';

// Route: POST /api/photos/add-photo
router.post('/add-photo', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: "الرجاء رفع صورة" });

        const { head, name, details } = req.body;
        
        // تحويل مسار الملف لشكل يفهمه المتصفح (استبدال \ بـ / في ويندوز)
        const filePath = req.file.path.replace(/\\/g, "/");

        const newPhoto = new Photo({
            head,
            name,
            details,
            imageUrl: filePath, 
            // user: req.user._id // إذا كنتِ تستخدمين Auth middleware
        });

        await newPhoto.save();
        res.status(201).json({ message: "تم الحفظ بنجاح", photo: newPhoto });
    } catch (error) {
        res.status(500).json({ message: "خطأ في السيرفر", error: error.message });
    }
});