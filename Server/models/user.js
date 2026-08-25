const mongoose = require("mongoose");
const { Schema } = mongoose;

const userSchema = new Schema({
    name: { type: String },
    email: { type: String },
    otp: { type: String },
    cart: [
        {
            product: { type: Schema.Types.ObjectId, ref: "products" },
            quality: { type: Number },
        }
    ]
});

mongoose.model("users", userSchema);
