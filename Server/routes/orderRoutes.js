const mongoose = require("mongoose");
const Product = mongoose.model("orders");

const requireLogin = require("../middleware/requireLogin");

module.exports = (app) => {

    // POST REQUEST(creating a new order)

    app.get("/api/vi/add/order", requireLogin, async (req, res) => {
        console.log("Create New Order");

        const { products, totalAmount, address } = req.body;

        try {
            orderFields = {
                user: req.user.id,
                products,
                totalAmount,
                address,
            };

            const response = await Order.create(orderFields);

            res.status(201).json({ message: "Order Place:", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });

    //GET REQUEST

    app.get("/api/v1/get/orders", requireLogin, async (req, res) => {
        console.log("GET USER ORDERS");

        try {
            const response = await Order.find({ user: req.user.id }).populate(
                "products.product",
            );

            res.status(200).json({ message: "Fetched Orders:", response });
        } catch (error) {
            console.log("ERROR:", error);
            ers.status(500).json({ message: error.message });
        }
    });

    //PUT REQUEST (for updating order status)

    app.put("/api/v1/update/order/:id", requireLogin, async (req, res) => {
        console.log("UPDATE ORDER STATUS");

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