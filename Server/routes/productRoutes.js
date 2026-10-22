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

    // SEARCH PRODUCTS
    app.get(["/api/v1/products/search", "/api/v1/products/search/:query"], async (req, res) => {
        try {
            let queryText = req.params.query ? decodeURIComponent(req.params.query).trim() : "";
            const page = Math.max(1, parseInt(req.query.page, 10) || 1);
            const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 10));
            const skip = (page - 1) * limit;

            let mongoFilter = buildMongoQuery(req.query);

            if (queryText) {
                let baseQuery = queryText;
                if (baseQuery.length > 3 && baseQuery.toLowerCase().endsWith("s")) {
                    baseQuery = baseQuery.slice(0, -1);
                }
                const regexPattern = new RegExp(baseQuery, "i");

                mongoFilter.$and = mongoFilter.$and || [];
                mongoFilter.$and.push({
                    $or: [
                        { title: { $regex: regexPattern } },
                        { category: { $regex: regexPattern } }
                    ]
                });
            }

            const totalProducts = await Product.countDocuments(mongoFilter);
            const products = await Product.find(mongoFilter)
                .sort({ _id: -1 })
                .skip(skip)
                .limit(limit);

            res.status(200).json({
                message: "Search Results:",
                response: products,
                pagination: {
                    total: totalProducts,
                    page,
                    limit,
                    totalPages: Math.ceil(totalProducts / limit) || 1
                }
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // DISJUNCTIVE FACETS AGGREGATION
    app.get("/api/v1/products/facets", async (req, res) => {
        try {
            let queryText = req.query.q ? decodeURIComponent(req.query.q).trim() : "";

            const buildMatch = (excludeField) => {
                const match = buildMongoQuery(req.query, { exclude: excludeField ? [excludeField] : [] });
                if (queryText) {
                    let baseQuery = queryText;
                    if (baseQuery.length > 3 && baseQuery.toLowerCase().endsWith("s")) {
                        baseQuery = baseQuery.slice(0, -1);
                    }
                    const regexPattern = new RegExp(baseQuery, "i");
                    match.$and = match.$and || [];
                    match.$and.push({
                        $or: [
                            { title: { $regex: regexPattern } },
                            { category: { $regex: regexPattern } }
                        ]
                    });
                }
                return match;
            };

            // 1. Determine category: explicit query param OR top category from matching search query
            let selectedCategory = req.query.category ? req.query.category.trim() : null;

            if (!selectedCategory && queryText) {
                const topCategoryMatch = await Product.aggregate([
                    { $match: buildMatch() },
                    { $group: { _id: "$category", count: { $sum: 1 } } },
                    { $sort: { count: -1 } }, { $limit: 1 }
                ]);
                if (topCategoryMatch.length > 0) {
                    selectedCategory = topCategoryMatch[0]._id;
                }
            }

            // 2. Fetch spec definitions for the category
            let activeCategoryDef = [];
            if (selectedCategory) {
                const categoryKey = Object.keys(categoryDefs).find(
                    (k) => k.toLowerCase() === selectedCategory.toLowerCase()
                );
                if (categoryKey) {
                    activeCategoryDef = categoryDefs[categoryKey].filter((d) => d.filterable);
                }
            }

            const facetBranches = {
                total: [
                    { $match: buildMatch() },
                    { $count: "count" }
                ],
                price: [
                    { $match: buildMatch("price") },
                    {
                        $group: {
                            _id: null,
                            min: { $min: "$price" },
                            max: { $max: "$price" }
                        }
                    }
                ],
                categories: [
                    { $match: buildMatch("category") },
                    { $group: { _id: "$category", count: { $sum: 1 } } },
                    { $project: { name: "$_id", count: 1, _id: 0 } }
                ]
            };

            // 3. Build dynamic aggregation branches for each attribute
            activeCategoryDef.forEach((def) => {
                const attrField = `$attributes.${def.key}`;
                if (def.type === "bool") {
                    facetBranches[`attr_${def.key}`] = [
                        { $match: buildMatch(def.key) },
                        { $match: { [attrField.replace('$', '')]: true } },
                        { $count: "trueCount" }
                    ];
                } else {
                    facetBranches[`attr_${def.key}`] = [
                        { $match: buildMatch(def.key) },
                        { $unwind: attrField },
                        { $group: { _id: attrField, count: { $sum: 1 } } }, { $sort: { _id: 1 } },
                        { $project: { value: "$_id", count: 1, _id: 0 } }
                    ];
                }
            });

            const aggregateResult = await Product.aggregate([{ $facet: facetBranches }]);
            const rawFacets = aggregateResult[0] || {};

            const total = rawFacets.total?.[0]?.count || 0;
            const price = rawFacets.price?.[0]
                ? { min: rawFacets.price[0].min, max: rawFacets.price[0].max }
                : { min: 0, max: 100000 };
            const categories = rawFacets.categories || [];

            const attributes = activeCategoryDef.map((def) => {
                const branchData = rawFacets[`attr_${def.key}`] || [];
                if (def.type === "bool") {
                    return {
                        key: def.key,
                        label: def.label,
                        type: def.type,
                        unit: def.unit || "",
                        trueCount: branchData[0]?.trueCount || 0
                    };
                }
                return {
                    key: def.key,
                    label: def.label,
                    type: def.type,
                    unit: def.unit || "",
                    options: branchData
                };
            });

            res.status(200).json({
                total,
                selectedCategory,
                price,
                categories,
                attributes
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // UPDATE PRODUCT BY ID
    app.put("/api/v1/products/:id", async (req, res) => {
        try {
            const { id } = req.params;
            const updatedProduct = await Product.findByIdAndUpdate(
                id,
                { $set: req.body },
                { returnDocument: 'after' }
            );

            if (!updatedProduct) {
                return res.status(404).json({ message: "Product not found" });
            }

            res.status(200).json({
                message: "Product updated successfully",
                response: updatedProduct
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });

    // DELETE PRODUCT BY ID
    app.delete("/api/v1/products/:id", async (req, res) => {
        try {
            const { id } = req.params;
            const deletedProduct = await Product.findByIdAndDelete(id);

            if (!deletedProduct) {
                return res.status(404).json({ message: "Product not found" });
            }

            res.status(200).json({
                message: "Product deleted successfully",
                response: deletedProduct
            });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    });
};