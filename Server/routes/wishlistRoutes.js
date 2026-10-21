const mongoose = require("mongoose");
const User = mongoose.model("users");
const requireLogin = require("../middleware/requireLogin");

module.exports = (app) => {
    // GET WISHLIST
    app.get("/api/v1/get/wishlist", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id).populate("wishlist");
            res.status(200).json({ wishlist: user.wishlist || [] });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // ADD ITEM TO WISHLIST
    app.post("/api/v1/wishlist/add", requireLogin, async (req, res) => {
        const { productId } = req.body;
        try {
            const user = await User.findByIdAndUpdate(
                req.user.id,
                { $addToSet: { wishlist: productId } },
                { returnDocument: "after" } // Updated option here
            ).populate("wishlist");

            res.status(200).json({ message: "Added to wishlist", wishlist: user.wishlist });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // REMOVE ITEM FROM WISHLIST
    app.delete("/api/v1/wishlist/remove/:productId", requireLogin, async (req, res) => {
        const { productId } = req.params;
        try {
            const user = await User.findByIdAndUpdate(
                req.user.id,
                { $pull: { wishlist: productId } },
                { returnDocument: "after" } // Updated option here
            ).populate("wishlist");

            res.status(200).json({ message: "Removed from wishlist", wishlist: user.wishlist });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};