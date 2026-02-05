import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './src/config/db.js';
import authRoutes from './src/modules/auth/auth.routes.js';
import userRoutes from './src/modules/users/user.routes.js';

dotenv.config();
await connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// ... الميدل ويرز

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

const PORT = process.env.PORT || 3006;

//  هذا الجزء قبل app.listen
app.use((err, req, res, next) => {
  const statusCode = err.status || 500;
  res.status(statusCode).json({
    message: err.message || 'حدث خطأ غير متوقع في السيرفر',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});
app.listen(PORT, () =>
  console.log(` Server running on port ${PORT}`)
);



