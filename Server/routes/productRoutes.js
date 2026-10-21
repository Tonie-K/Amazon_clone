const mongoose = require("mongoose");
const Product = mongoose.model("products");
const categoryDefs = require("../config/categoryDefs");
const { buildMongoQuery } = require("../utils/querybuilder");

module.exports = (app) => {

    // GET CATEGORY ATTRIBUTES DEFINITIONS
    app.get("/api/v1/categories/:name/attributes", (req, res) => {
        try {
            const categoryName = decodeURIComponent(req.params.name).trim();
            const key = Object.keys(categoryDefs).find(
                (k) => k.toLowerCase() === categoryName.toLowerCase()
            );
            const definitions = key ? categoryDefs[key] : [];
            res.status(200).json({ definitions });
        } catch (error) {
            res.status(500).json({ message: error.message, definitions: [] });
        }
    });

    app.get(["/api/v1/products/search", "/api/v1/products/search/:query"], async (req, res) => {
        try {
            let queryText = req.params.query ? decodeURIComponent(req.params.query).trim() : "";

            // Page & Limit
            const page = parseInt(req.query.page, 10) || 1;
            const limit = parseInt(req.query.limit, 10) || 10;
            const skip = (page - 1) * limit;

            // Build conditions from whitelist & category definitions
            let mongoFilter = buildMongoQuery(req.query);

            // Add text regex matching if search query term is present
            if (queryText) {
                let baseQuery = queryText;
                if (baseQuery.length > 3 && baseQuery.toLowerCase().endsWith("s")) {
                    baseQuery = baseQuery.slice(0, -1);
                }
                const regexPattern = new RegExp(baseQuery, "i");

                mongoFilter.$or = [
                    { title: { $regex: regexPattern } },
                    { category: { $regex: regexPattern } },
                    { description: { $regex: regexPattern } },
                ];
            }

            const totalProducts = await Product.countDocuments(mongoFilter);
            const products = await Product.find(mongoFilter)
                .skip(skip)
                .limit(limit);

            res.status(200).json({
                message: "Search Results:",
                response: products,
                pagination: {
                    total: totalProducts,
                    page,
                    limit,
                    totalPages: Math.ceil(totalProducts / limit)
                }
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // GET FACETS FOR CURRENT RESULT SET
    app.get("/api/v1/products/facets", async (req, res) => {
        try {
            const mongoFilter = buildMongoQuery(req.query);

            const facetsResult = await Product.aggregate([
                { $match: mongoFilter },
                {
                    $facet: {
                        priceRange: [
                            {
                                $group: {
                                    _id: null,
                                    minPrice: { $min: "$price" },
                                    maxPrice: { $max: "$price" }
                                }
                            }
                        ],
                        categoryCounts: [
                            { $group: { _id: "$category", count: { $sum: 1 } } }
                        ]
                    }
                }
            ]);

            const facets = facetsResult[0];
            const minPrice = facets.priceRange[0]?.minPrice || 0;
            const maxPrice = facets.priceRange[0]?.maxPrice || 100000;

            res.status(200).json({
                facets: {
                    minPrice,
                    maxPrice,
                    categories: facets.categoryCounts
                }
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};