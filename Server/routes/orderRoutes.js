const mongoose = require("mongoose");
const Order = mongoose.model("orders");
const requireLogin = require("../middleware/requireLogin");

module.exports = (app) => {
    // POST: Create a new order
    app.post("/api/v1/add/order", requireLogin, async (req, res) => {
        const { products, totalAmount, address } = req.body;

        try {
            const orderFields = {
                user: req.user.id,
                products,
                totalAmount,
                address,
            };

            const response = await Order.create(orderFields);
            res.status(201).json({ message: "Order Placed", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });

    // GET: Fetch user orders
    app.get("/api/v1/get/orders", requireLogin, async (req, res) => {
        try {
            const response = await Order.find({ user: req.user.id }).populate(
                "products.product"
            );
            res.status(200).json({ message: "Fetched Orders:", response });
        } catch (error) {
            console.log("ERROR:", error);
            res.status(500).json({ message: error.message });
        }
    });

    // PUT: Update order status
    app.put("/api/v1/update/order/:id", requireLogin, async (req, res) => {
        const { id } = req.params;
        const { status } = req.body;

        try {
            const response = await Order.updateOne({ _id: id }, { status });
            res.status(200).json({ message: "Updated: ", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });
};