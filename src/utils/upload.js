import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const userId = req.user ? req.user._id.toString() : 'anonymous';
    const uploadPath = path.join(__dirname, '../../uploads', userId);

    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const utf8Name = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, `${utf8Name}`);

  }
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf') {
    cb(null, true);
  } else {
    cb(null, true); 
  }
};

const upload = multer({
  storage: storage,
  // fileFilter: fileFilter //   لمنع أنواع معينة
});

export default upload;