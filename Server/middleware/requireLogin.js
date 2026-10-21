// Reusable Code to Verify JWT Token
const jwt = require("jsonwebtoken");

const requireLogin = (req, res, next) => {
    const token = req.headers["authorization"];
    const secret = process.env.JWT_SECRET || "fallback_secret_key";

    jwt.verify(token, secret, async (err, payload) => {
        if (err) {
            return res
                .status(401)
                .json({ message: "You have to log in to continue." });
        }
        req.user = payload;
        next();
    });
};

module.exports = requireLogin;