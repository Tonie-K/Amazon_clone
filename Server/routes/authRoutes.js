const crypto = require("crypto");
const mongoose = require("mongoose");
const User = mongoose.model("users");
const jwt = require("jsonwebtoken");
const requireLogin = require("../middleware/requireLogin");

const otpLength = 6;
const OTP_TTL_MS = 5 * 60 * 1000;

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

            await User.updateOne(
                { email },
                { otp, otpExpiresAt: new Date(Date.now() + OTP_TTL_MS) },
                { upsert: true }
            );

            console.log(`OTP for ${email}: ${otp}`);
            res.status(200).json({ message: "OTP sent successfully" });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // VERIFY OTP
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

            user.otp = undefined;
            user.otpExpiresAt = undefined;
            await user.save();

            const payload = { id: user._id, email: user.email };
            const secret = process.env.JWT_SECRET || "fallback_secret_key";
            const expiresIn = process.env.JWT_EXPIRES_IN || "7d";

            const token = jwt.sign(payload, secret, { expiresIn });

            res.status(200).json({
                message: "Login Success",
                token,
                user: { id: user._id, email: user.email, name: user.name },
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // GET CURRENT USER
    app.get("/api/v1/current/user", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id, "-otp -otpExpiresAt");
            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }
            res.status(200).json({ message: "User Found", user });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // UPDATE USER PROFILE NAME
    app.put("/api/v1/update/profile", requireLogin, async (req, res) => {
        try {
            const { name } = req.body;
            const user = await User.findByIdAndUpdate(
                req.user.id,
                { name: name?.trim() },
                { new: true }
            ).select("-otp -otpExpiresAt");

            res.status(200).json({
                message: "Profile updated successfully",
                user: { id: user._id, email: user.email, name: user.name },
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};