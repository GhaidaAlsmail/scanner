import { createUser, findByEmail } from "../modules/users/user.repository.js"; // استيراد الدوال مباشرة
import bcrypt from 'bcrypt';
import mongoose from "mongoose";
import boxen from 'boxen';
import dotenv from 'dotenv';

dotenv.config();

async function adminSeed() {
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/scanner';
    
    try {
        await mongoose.connect(mongoUri);
        console.log("Connected to MongoDB...");

        const adminEmail = process.env.ADMIN_EMAIL || 'manager@company.com';
      const adminPassword = process.env.ADMIN_PASSWORD || 'Manager@2024';
    const hashedPwd = await bcrypt.hash(adminPassword, 10);

    // 2. الحقن في قاعدة البيانات
    await createUser({
        name: 'General Manager',
        email: adminEmail,
        passwordHash: hashedPwd, // هنا الخطأ كان: استخدمي hashedPwd وليس adminPassword
        role: 'admin',
        isVerified: true, // ليتجاوز نظام التفعيل
        isAdmin: true,    // أضيفيها أيضاً لأن الموديل يحتوي على isAdmin
        is_active: true
    });

    console.log(boxen("Success: Admin account is now fixed and hashed!"));


        const message = `Admin Created Successfully!\nEmail: ${adminEmail}\nPassword: ${adminPassword}`;
        console.log(boxen(message, { padding: 1, borderColor: 'green', borderStyle: 'round' }));

    } catch (error) {
        console.error("Seed Error:", error);
    } finally {
        await mongoose.disconnect();
    }
}

adminSeed();