// Reusable Code to Verify JWT Token
const jwt = require("jsonwebtoken");

const requireLogin = (req, res, next) => {
    const token = req.headers["authorization"];
    console.log(token);

    jwt.verify(token, process.env.JWT_SECRET, async (err, payload) => {
        console.log(err);
        if (err) {
            console.log("UNAUTHORISED");
            return res
                .status(401)
                .json({ message: "You have to log in to continue." });
        }
        req.user = payload;
        next();
    });
};

module.exports = requireLogin;