const mongoose = require("mongoose");
const { Schema } = mongoose;

const orderSchema = new Schema(
    {
        user: { type: Schema.Types.ObjectId, ref: "users" },
        products: [
            {
                product: { type: Schema.Types.ObjectId, ref: "products" },
                quality: { type: Number },
            },
        ],
        totalAmount: { type: Number },
        address: { type: String },
        status: { type: String, default: "Pending" },
    },
    { timestamps: true },
);

mongoose.model("orders", orderSchema);