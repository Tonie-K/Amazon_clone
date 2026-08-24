const mongoose = require("mongoose");
const { Schema } = mongoose;

const userSchema = new Schema({
    name: { type: String },
    email: { type: String },
    otp: { type: String },
});

mongoose.model("users", userSchema);
