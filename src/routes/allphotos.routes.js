// Route: GET /api/photos/all
router.get('/all', async (req, res) => {
    try {
        const photos = await Photo.find().sort({ createdAt: -1 });
        
        // ملاحظة: نرسل البيانات كـ 'photos' ليتطابق مع كود فلاتر fetchAllPhotos
        res.status(200).json({ photos: photos });
    } catch (error) {
        res.status(500).json({ message: "خطأ في جلب البيانات" });
    }
});