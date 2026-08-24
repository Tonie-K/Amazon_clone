// Authentication Routes
const mongoose = require("mongoose");
const User = mongoose.model("users");
const jwt = require("jsonwebtoken"); // npm i jsonwebtoken

const requireLogin = require("../middleware/requireLogin");

const otpLength = 6;

module.exports = (app) => {
    // SEND OTP
    app.post("/api/v1/send/email/otp", async (req, res) => {
        try {
            const { email } = req.body; // Get email from request

            //   Generate the OTP
            const digits = "0123456789";
            let newOTP = "";
            for (let i = 0; i < otpLength; i++) {
                newOTP += digits[Math.floor(Math.random() * 10)];
            }
            console.log("newOTP: ", newOTP);

            //   Check if the user already exists
            const user = await User.findOne({ email });

            if (!user) {
                const response = await User.create({ email, otp: newOTP });
                res.status(201).json({ message: "OTP Sent Succesfully" }); s
            } else {
                const response = await User.updateOne({ email, otp: newOTP });
                res.status(201).json({ message: "OTP Sent Succesfully" });
            }
        } catch (error) {
            console.log(error);
            res.status(500).send({ message: error.message });
        }
    });

    // VERIFY OTP | Create Auth Token & Send it to Client
    app.post("/api/v1/verify/email/otp", async (req, res) => {
        try {
            const { email, otp } = req.body; // Get email from request

            // Check if the user exists
            const user = await User.findOne({ email });

            if (user && user.otp == otp) {
                //  CREATE TOKEN TO SEND PAYLOAD
                const payload = {
                    id: user._id,
                    email: user.email,
                };

                const token = jwt.sign(payload, process.env.JWT_SECRET, {
                    expiresIn: process.env.JWT_EXPIRES_IN,
                });

                res.status(200).json({ message: "Login Success", token });
            }
        } catch (error) {
            console.log(error);
            res.status(500).send({ message: error.message });
        }
    });

    app.get("/api/v1/current/user", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id, "-otp");

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            res.status(200).json({ message: "User Found. Current User: ", user });
        } catch (error) {
            console.log(error);
            res.status(500).send({ message: error.message });
        }
    });
};
