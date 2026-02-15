
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