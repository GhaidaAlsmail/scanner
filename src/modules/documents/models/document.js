import mongoose from 'mongoose';
import mongoosePaginate from 'mongoose-paginate-v2'; 

const documentSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    
    title: { type: String, required: true },
    pdfPath: { type: String, required: true },
    region: { type: String, required: true, index: true }, 
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdAt: { type: Date, default: Date.now }
});

documentSchema.plugin(mongoosePaginate);

export default mongoose.model('Document', documentSchema);