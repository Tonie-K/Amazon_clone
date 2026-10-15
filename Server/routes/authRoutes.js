// Authentication Routes
const crypto = require("crypto");
const mongoose = require("mongoose");
const User = mongoose.model("users");
const jwt = require("jsonwebtoken"); // npm i jsonwebtoken

const requireLogin = require("../middleware/requireLogin");

const otpLength = 6;
const OTP_TTL_MS = 5 * 60 * 1000; // OTP valid for 5 minutes

const normalizeEmail = (email) =>
    typeof email === "string" ? email.trim().toLowerCase() : "";

module.exports = (app) => {
    // SEND OTP
    app.post("/api/v1/send/email/otp", async (req, res) => {
        try {
            const email = normalizeEmail(req.body.email);
            if (!email) {
                return res.status(400).json({ message: "Email is required" });
            }

            const otp = crypto
                .randomInt(0, 10 ** otpLength)
                .toString()
                .padStart(otpLength, "0");

            // Creates the user if they don't exist, otherwise refreshes the OTP
            await User.updateOne(
                { email },
                { otp, otpExpiresAt: new Date(Date.now() + OTP_TTL_MS) },
                { upsert: true },
            );

            // TODO: send this by email (Nodemailer / Resend / SendGrid).
            // For development the OTP is only printed in the server console.
            console.log(`OTP for ${email}: ${otp}`);

            res.status(200).json({ message: "OTP sent successfully" });
        } catch (error) {
            console.log(error);
            res.status(500).json({ message: error.message });
        }
    });

    // VERIFY OTP | Create Auth Token & Send it to Client
    app.post("/api/v1/verify/email/otp", async (req, res) => {
        try {
            const email = normalizeEmail(req.body.email);
            const otp = String(req.body.otp ?? "");

            const user = await User.findOne({ email });

            if (
                !user ||
                !user.otp ||
                user.otp !== otp ||
                !user.otpExpiresAt ||
                user.otpExpiresAt < new Date()
            ) {
                return res.status(400).json({ message: "Invalid or expired OTP" });
            }

            // One-time use: clear the OTP once it has been verified
            user.otp = undefined;
            user.otpExpiresAt = undefined;
            await user.save();

            const payload = { id: user._id, email: user.email };
            const token = jwt.sign(payload, process.env.JWT_SECRET, {
                expiresIn: process.env.JWT_EXPIRES_IN,
            });

            res.status(200).json({
                message: "Login Success",
                token,
                user: { id: user._id, email: user.email, name: user.name },
            });
        } catch (error) {
            console.log(error);
            res.status(500).json({ message: error.message });
        }
    });

    // CURRENT USER (also used by the app to check a saved token is still valid)
    app.get("/api/v1/current/user", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id, "-otp -otpExpiresAt");

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            res.status(200).json({ message: "User Found. Current User: ", user });
        } catch (error) {
            console.log(error);
            res.status(500).json({ message: error.message });
        }
    });
};