const mongoose = require("mongoose");
const Product = mongoose.model("products");

module.exports = (app) => {
    // GET ALL PRODUCTS
    app.get("/api/v1/get/products", async (req, res) => {
        try {
            const response = await Product.find();
            res.status(200).json({ message: "Fetched Products: ", response });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // GET SINGLE PRODUCT
    app.get("/api/v1/get/product/:id", async (req, res) => {
        const { id } = req.params;
        try {
            const response = await Product.findById(id);
            if (!response) {
                return res.status(404).json({ message: "Product not found" });
            }
            res.status(200).json({ message: "Fetched Product:", response });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // SEARCH PRODUCTS
    app.get("/api/v1/products/search/:query", async (req, res) => {
        let { query } = req.params;
        try {
            query = decodeURIComponent(query).trim();
            let baseQuery = query;
            if (baseQuery.length > 3 && baseQuery.toLowerCase().endsWith("s")) {
                baseQuery = baseQuery.slice(0, -1);
            }
            const regexPattern = new RegExp(baseQuery, "i");

            const products = await Product.find({
                $or: [
                    { title: { $regex: regexPattern } },
                    { category: { $regex: regexPattern } },
                    { description: { $regex: regexPattern } },
                ],
            });

            res.status(200).json({ message: "Search Results:", response: products });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};