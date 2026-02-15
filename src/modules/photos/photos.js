import mongoose from 'mongoose';

const PhotoSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.ObjectId, ref: 'User', required: true },
  head: { type: String },    // العنوان
  name: { type: String },    // اسم الموظف
  details: { type: String }, // التفاصيل
  path: { type: String, required: true },
  filename: { type: String },
  createdAt: { type: Date, default: Date.now }
});

const Photo = mongoose.model('Photo', PhotoSchema);
export default Photo; 