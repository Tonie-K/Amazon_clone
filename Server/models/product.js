const mongoose = require("mongoose");
const { Schema } = mongoose;

const productSchema = new Schema({
    title: { type: String, required: true },
    imageUrl: { type: String, required: true },
    description: { type: String, required: true },
    price: { type: Number, required: true, index: true },
    category: { type: String, required: true, index: true },
    stock: { type: Number, required: true },
    rating: { type: Number, default: 0, index: true },
    specBadge: { type: String, default: "" },
    isSponsored: { type: Boolean, default: false },
    attributes: { type: Schema.Types.Mixed, default: {} } // MongoDB dynamic subdocument
}, { timestamps: true });

// Compound Indexes for high-frequency queries
productSchema.index({ category: 1, price: 1 });
productSchema.index({ category: 1, rating: -1 });

// Wildcard index on attributes for dynamic field querying
productSchema.index({ "attributes.$**": 1 });

mongoose.model("products", productSchema);