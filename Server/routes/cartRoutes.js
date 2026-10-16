const mongoose = require("mongoose");
const User = mongoose.model("users");
const requireLogin = require("../middleware/requireLogin");

module.exports = (app) => {
    // GET USER CART
    app.get("/api/v1/get/cart", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id).populate("cart.product");
            res.status(200).json({ cart: user.cart || [] });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // ADD ITEM TO CART / INCREMENT QUANTITY
    app.post("/api/v1/cart/add", requireLogin, async (req, res) => {
        const { productId, quantity = 1 } = req.body;
        try {
            const user = await User.findById(req.user.id);
            const itemIndex = user.cart.findIndex(
                (item) => item.product.toString() === productId
            );

            if (itemIndex > -1) {
                user.cart[itemIndex].quantity += quantity;
            } else {
                user.cart.push({ product: productId, quantity });
            }

            await user.save();
            const updatedUser = await User.findById(req.user.id).populate("cart.product");
            res.status(200).json({ message: "Item added to cart", cart: updatedUser.cart });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // UPDATE ITEM QUANTITY OR REMOVE IF QUANTITY IS 0
    app.put("/api/v1/cart/update", requireLogin, async (req, res) => {
        const { productId, quantity } = req.body;
        try {
            const user = await User.findById(req.user.id);
            if (quantity <= 0) {
                user.cart = user.cart.filter((item) => item.product.toString() !== productId);
            } else {
                const item = user.cart.find((item) => item.product.toString() === productId);
                if (item) item.quantity = quantity;
            }

            await user.save();
            const updatedUser = await User.findById(req.user.id).populate("cart.product");
            res.status(200).json({ message: "Cart updated", cart: updatedUser.cart });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // CLEAR ENTIRE CART
    app.delete("/api/v1/cart/clear", requireLogin, async (req, res) => {
        try {
            const user = await User.findById(req.user.id);
            user.cart = [];
            await user.save();
            res.status(200).json({ message: "Cart cleared", cart: [] });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};