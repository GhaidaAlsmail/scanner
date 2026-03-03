import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path'; 
import fs from 'fs'; 
import { connectDB } from './src/config/db.js';
import authRoutes from './src/modules/auth/auth.routes.js';
import userRoutes from './src/modules/users/user.routes.js';
import photoRoutes from './src/routes/photos.routes.js'; 
import documentRoutes from './src/modules/documents/routes/documents.routes.js';

dotenv.config();
await connectDB();

const app = express();

// 1. إعدادات الوصول للملفات (Static Files)
app.use('/uploads', (req, res, next) => {
    try {
        req.url = decodeURIComponent(req.url);
        next();
    } catch (e) { next(); }
}, express.static(path.join(process.cwd(), 'uploads')));

app.use(cors());

// رفع الحد للملفات الكبيرة
app.use(express.json({ limit: '100mb' })); 
app.use(express.urlencoded({ extended: true, limit: '100mb', parameterLimit: 50000 }));

app.use('/api', (req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
}); 

// 2. الروابط (Routes) - التعديل الجوهري هنا
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/photos', photoRoutes); 

// قمنا بتغيير documents إلى pdf ليتطابق مع طلب Flutter
app.use('/api/pdf', documentRoutes); 
// ويمكنك ترك هذا أيضاً كاحتياط إذا كان هناك أجزاء أخرى تستخدمه
app.use('/api/documents', documentRoutes);

const PORT = process.env.PORT || 3006;

// معالجة الأخطاء
app.use((err, req, res, next) => {
  const statusCode = err.status || 500;
  console.error("Global Error Handler:", err.message);
  res.status(statusCode).json({
    message: err.message || 'حدث خطأ غير متوقع في السيرفر',
  });
});

app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);