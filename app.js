import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path'; 
import { fileURLToPath } from 'url'; 
import { connectDB } from './src/config/db.js';
import authRoutes from './src/modules/auth/auth.routes.js';
import userRoutes from './src/modules/users/user.routes.js';
import photoRoutes from './src/routes/photos.routes.js'; 
import documentRoutes from './src/modules/documents/routes/documents.routes.js';

dotenv.config();
await connectDB();

const app = express();

app.use('/uploads', (req, res, next) => {
    try {
        req.url = decodeURIComponent(req.url);
        next();
    } catch (e) {
        next();
    }
}, express.static(path.join(process.cwd(), 'uploads')));

app.use('/pdfs', (req, res, next) => {
    try {
        req.url = decodeURIComponent(req.url);
        next();
    } catch (e) {
        next();
    }
}, express.static(path.join(process.cwd(), 'pds')));

app.use(cors());

// رفع الحد ليتناسب مع ملفات الـ PDF الكبيرة (A3)
app.use(express.json({ limit: '100mb' })); 
app.use(express.urlencoded({ extended: true, limit: '100mb', parameterLimit: 50000 }));

app.use('/api', (req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
}); 

// // الروابط (Routes)
// app.use('/api/auth', authRoutes);
// app.use('/api/users', userRoutes);
// app.use('/api/photos', photoRoutes); 
// app.use('/api/documents', documentRoutes);
app.use('/uploads/pdfs', (req, res, next) => {
    try {
        req.url = decodeURIComponent(req.url);
        next();
    } catch (e) { next(); }
}, express.static(path.join(process.cwd(), 'uploads/pdfs')));

// الروابط (Routes)
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/photos', photoRoutes); 
app.use('/api/documents', documentRoutes);
const PORT = process.env.PORT || 3006;

// معالجة الأخطاء
app.use((err, req, res, next) => {
  const statusCode = err.status || 500;
  console.error("Global Error Handler:", err.message);
  res.status(statusCode).json({
    message: err.message || 'حدث خطأ غير متوقع في السيرفر',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});

app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);