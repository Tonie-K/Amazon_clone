const mongoose = require("mongoose");
const { Schema } = mongoose;

const productSchema = new Schema({
    title: { type: String },
    imageUrl: { type: String },
    description: { type: String },
    price: { type: Number },
    category: { type: String },
    stock: { type: Number },
    rating: { type: Number },
});

mongoose.model("products", productSchema)