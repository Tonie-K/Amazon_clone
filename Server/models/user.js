const mongoose = require("mongoose");
const { Schema } = mongoose;

const userSchema = new Schema({
    name: { type: String },
    email: { type: String, unique: true, lowercase: true, trim: true },
    otp: { type: String },
    otpExpiresAt: { type: Date },
    cart: [
        {
            product: { type: Schema.Types.ObjectId, ref: "products" },
            quality: { type: Number },
        }
    ]
});

mongoose.model("users", userSchema);