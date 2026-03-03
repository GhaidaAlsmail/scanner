// import { createUser } from "../modules/users/user.repository.js";
import User from "../modules/users/user.model.js";
import bcrypt from "bcrypt";
import mongoose from "mongoose";
import boxen from "boxen";
import dotenv from "dotenv";
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config({ path: path.join(__dirname, '../../.env') });

// dotenv.config();

async function adminSeed() {
    const mongoUri = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/scanner";

    try {
        await mongoose.connect(mongoUri);
        console.log("Connected to MongoDB");

        const adminUsername = process.env.ADMIN_USERNAME || "manager";
        const adminPassword = process.env.ADMIN_PASSWORD || "Manager@2024Password";
        const adminEmail = process.env.ADMIN_EMAIL || `${adminUsername}@system.local`;

        const hashedPwd = await bcrypt.hash(adminPassword, 10);

        let existingAdmin = await User.findOne({ 
            $or: [{ username: adminUsername }, { role: "admin" }] 
        });

        if (existingAdmin) {
            existingAdmin.name = "General Manager";
            existingAdmin.username = adminUsername;
            existingAdmin.email = adminEmail; 
            existingAdmin.passwordHash = hashedPwd;
            existingAdmin.isVerified = true;
            existingAdmin.isAdmin = true;
            existingAdmin.role = "admin"; 
            existingAdmin.is_active = true;
            existingAdmin.city = "حمص";

            await existingAdmin.save();

            console.log(
                boxen("Admin Updated Successfully!", {
                    padding: 1,
                    borderColor: "yellow",
                    borderStyle: "round",
                })
            );
        } else {
            
            await User.create({
                name: "General Manager",
                username: adminUsername,
                email: adminEmail,
                passwordHash: hashedPwd,
                role: "admin",
                isVerified: true,
                isAdmin: true,
                is_active: true,
                city: "حمص"
            });
            console.log(
                boxen("Admin Created Successfully!", {
                    padding: 1,
                    borderColor: "green",
                    borderStyle: "round",
                })
            );
        }

        console.log(
            boxen(`Username: ${adminUsername}\nPassword: ${adminPassword}`, {
                padding: 1,
                borderColor: "cyan",
                borderStyle: "round",
            })
        );

    } catch (error) {
        console.error("Seed Error:", error);
    } finally {
        await mongoose.disconnect();
        console.log("Disconnected from MongoDB");
    }
}
adminSeed();