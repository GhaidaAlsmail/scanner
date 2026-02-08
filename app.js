import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path'; // استيراد path بنظام import
import { fileURLToPath } from 'url'; // ضروري لتعريف __dirname
import { connectDB } from './src/config/db.js';
import authRoutes from './src/modules/auth/auth.routes.js';
import userRoutes from './src/modules/users/user.routes.js';
import photoRoutes from './src/routes/photos.routes.js'; // تأكدي من المسار وإضافة .js

dotenv.config();
await connectDB();

// إعداد __dirname يدوياً لأننا نستخدم ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.use(cors());
app.use(express.json());

// تقديم المجلدات الثابتة (الصور)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// الـ Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/photos', photoRoutes); // تم التعديل هنا

const PORT = process.env.PORT || 3006;

// معالجة الأخطاء
app.use((err, req, res, next) => {
  const statusCode = err.status || 500;
  res.status(statusCode).json({
    message: err.message || 'حدث خطأ غير متوقع في السيرفر',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});

app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);