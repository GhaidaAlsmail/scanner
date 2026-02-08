import mongoose from 'mongoose';

const PhotoSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  path: { type: String, required: true },
  filename: { type: String, required: true },
  mimetype: String,
  size: Number,
  createdAt: { type: Date, default: Date.now }
});

const Photo = mongoose.model('Photo', PhotoSchema);
export default Photo; // نقوم بتصدير الموديل كافتراضي