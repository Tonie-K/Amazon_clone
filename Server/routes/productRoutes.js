const mongoose = require("mongoose");
const Product = mongoose.model("products");

const requireLogin = require("../middleware/requireLogin");

//HTTP REQUEST 

module.exports = (app) => {

    // GET REQUEST FOR READING ALL PRODUCTS

    app.get("/api/v1/get/products", async (req, res) => {
        console.log("GET PRODUCTS");

        try {
            const response = await Product.find();
            res.status(200).json({ message: "Fetched Products: ", response });
        } catch (error) {
            console.log("ERROR: ", error)
            res.status(500).json({ message: error.message });
        }
    });

    //GET REQUEST FOR READING A SINGLE PRODUCT

    app.get("/api/v1/get/product/:id", async (req, res) => {
        console.log("GET SINGLE PRODUCT");

        const { id } = req.params;

        try {
            const response = await Product.findById(id);

            if (!response) {
                return res.status(404).json({ message: "Product not found" });
            }

            res.status(200).json({ message: "Fetched Product:", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });

    //POST REQUEST FOR ADDING A NEW PRODUCT
    app.post("/api/v1/add/product", requireLogin, async (req, res) => {
        console.log("ADD A NEW PRODUCT");

        const { title, imageUrl, description, price, category, stock, rating } = req.body;

        try {
            const product = await Product.findOne({ title });
            if (product) {
                return res.status(400).json({ message: "Product already exists! " });
            }

            productFields = {
                title,
                imageUrl,
                description,
                price,
                category,
                stock,
                rating,
            };

            const response = await Product.create(productFields);

            res.status(201).json({ message: "New Product Added:", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });

    app.put("/api/v1/update/product/:id", requireLogin, async (req, res) => {
        console.log("UPDATE PRODUCT");

        const { id } = req.params;
        const { title, imageURL, description, price, category, stock, rating } = req.body;

        try {
            const response = await Product.updateOne(
                { _id: id },
                { title, imageUrl, description, price, category, stock, rating },
            );

            res.status(200).json({ message: "Updated: ", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });

    app.delete("/api/v1/delete/product/:id", requireLogin, async (req, res) => {
        const { id } = req.params;

        try {
            const response = await Product.findByIdAndDelete(id);

            res.status(200).json({ message: "Deleted ", response });
        } catch (error) {
            console.log("ERROR: ", error);
            res.status(500).json({ message: error.message });
        }
    });
};