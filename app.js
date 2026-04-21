import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path'; 
// import fs from 'fs'; 
import { fileURLToPath } from 'url'; 
import { connectDB } from './src/config/db.js';
import authRoutes from './src/modules/auth/auth.routes.js';
import userRoutes from './src/modules/users/user.routes.js';
import photoRoutes from './src/routes/photos.routes.js'; 
import documentRoutes from './src/modules/documents/routes/documents.routes.js';

import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import rateLimit from 'express-rate-limit';
import xss from 'xss'; 

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


dotenv.config();
await connectDB();

const app = express();

// // 1. حماية رؤوس الطلبات (Headers) لمنع اكتشاف تقنيات السيرفر
// app.use(helmet());

// // 2. منع هجمات NoSQL Injection (تنظيف المدخلات من رموز $ و .)
// // الحل: تنظيف الجسم (body) والبيانات المدخلة مع استثناء الـ query إذا كان يسبب تعارضاً
// app.use(mongoSanitize({
//   replaceWith: '_',
//   allowDots: true // اختياري: يسمح بالنقاط في الأسماء إذا كنتِ تحتاجيها
// }));
// // 3. منع هجمات XSS (تنظيف النصوص من أكواد JS الخبيثة)
// // سنقوم بعمل Middleware بسيط لاستخدام مكتبة xss التي ثبتيها
// app.use((req, res, next) => {
//   if (req.body) {
//     for (const key in req.body) {
//       if (typeof req.body[key] === 'string') {
//         req.body[key] = xss(req.body[key]);
//       }
//     }
//   }
//   next();
// });

// // 4. حماية من هجمات التخمين (Brute Force)
// const limiter = rateLimit({
//   windowMs: 15 * 60 * 1000, // 15 دقيقة
//   max: 100, // 100 طلب فقط من كل جهاز
//   message: { message: 'عمليات كثيرة جداً، يرجى المحاولة لاحقاً' }
// });
// app.use('/api', limiter);

app.use((req, res, next) => {
    try {
        req.url = decodeURIComponent(req.url);
    } catch (e) { /* ignore error */ }
    next();
});

app.use('/uploads/pdfs', express.static(path.join(__dirname, 'uploads/pdfs')));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use(cors());
app.use(express.json({ limit: '500mb' })); 
app.use(express.urlencoded({ extended: true, limit: '500mb', parameterLimit: 50000 }));


app.use('/api', (req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
}); 


app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/photos', photoRoutes); 
app.use('/api/pdf', documentRoutes); 
app.use('/api/documents', documentRoutes);

const PORT = process.env.PORT || 3006;


app.use((err, req, res, next) => {
  const statusCode = err.status || 500;
  console.error("Global Error Handler:", err.stack); 
  res.status(statusCode).json({
    message: err.message || 'حدث خطأ غير متوقع في السيرفر',
  });
});

app.listen(PORT, () =>
  console.log(`### Server running on port ${PORT}`)
);