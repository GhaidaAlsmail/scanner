import mongoose from 'mongoose';

export const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log(' MongoDB connected');
  } catch (err) {
    console.error(' MongoDB error', err);
    process.exit(1);
  }
};

export const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    console.log(' MongoDB disconnected');
  } catch (err) {
    console.error(' MongoDB error', err);
    process.exit(1);
  }
};


// import mongoose from 'mongoose';
// import User from '../modules/users/user.model.js'; // تأكدي من صحة المسار لموديل المستخدم

// export const connectDB = async () => {
//   try {
//     await mongoose.connect(process.env.MONGO_URI);
//     console.log('🚀 MongoDB connected');

//     // تنفيذ التنظيف فوراً بعد الاتصال
//     const db = mongoose.connection.db;
//     const usersCollection = db.collection('users');

//     try {
//       // 1. حذف السجلات التالفة
//       const deleteResult = await usersCollection.deleteMany({
//         $or: [
//           { email: "" },
//           { email: " " },
//           { email: null }
//         ]
//       });
//       if (deleteResult.deletedCount > 0) {
//         console.log(`🧹 تم تنظيف ${deleteResult.deletedCount} سجلات تالفة`);
//       }

//       // 2. حذف الفهرس القديم
//       await usersCollection.dropIndex('email_1');
//       console.log(' تم حذف الفهرس القديم بنجاح');

//       // 3. إعادة بناء الفهارس بناءً على الموديل الجديد (Sparse)
//       await User.syncIndexes();
//       console.log(' تم تحديث نظام الفهارس (Sparse Index Ready)');

//     } catch (e) {
//       // إذا لم يجد الفهرس ليحذفه، سيعتبره مصلحاً مسبقاً
//       console.log(' نظام الفهارس سليم ولا يحتاج لتعديل');
//     }

//   } catch (err) {
//     console.error(' MongoDB connection error:', err);
//     process.exit(1);
//   }
// };