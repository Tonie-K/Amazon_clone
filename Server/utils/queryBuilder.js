const categoryDefs = require("../config/categoryDefs");

/**
 * Parses request query parameters against category definitions and returns a MongoDB query object.
 */
function buildMongoQuery(queryParams) {
    const { category, minPrice, maxPrice, minRating, ...otherParams } = queryParams;
    let queryObj = {};

    // 1. Top-level category filter
    let activeCategoryDef = null;
    if (category) {
        const trimmedCategory = category.trim();
        const categoryKey = Object.keys(categoryDefs).find(
            (k) => k.toLowerCase() === trimmedCategory.toLowerCase()
        );

        if (categoryKey) {
            queryObj.category = categoryKey;
            activeCategoryDef = categoryDefs[categoryKey];
        } else {
            queryObj.category = trimmedCategory;
        }
    }

    // 2. Top-level Price Range
    if (minPrice !== undefined || maxPrice !== undefined) {
        queryObj.price = {};
        if (minPrice !== undefined && minPrice !== "") queryObj.price.$gte = Number(minPrice);
        if (maxPrice !== undefined && maxPrice !== "") queryObj.price.$lte = Number(maxPrice);
    }

    // 3. Top-level Rating
    if (minRating !== undefined && minRating !== "") {
        queryObj.rating = { $gte: Number(minRating) };
    }

    // 4. Attribute Whitelisting & Condition Building
    if (activeCategoryDef) {
        activeCategoryDef.forEach((def) => {
            const paramVal = otherParams[def.key];
            if (paramVal === undefined || paramVal === null || paramVal === "") return;

            const attrPath = `attributes.${def.key}`;

            switch (def.type) {
                case "enum": {
                    // Supports comma-separated strings or arrays
                    const values = Array.isArray(paramVal)
                        ? paramVal
                        : paramVal.toString().split(",").map((s) => s.trim());
                    queryObj[attrPath] = { $in: values };
                    break;
                }

                case "number": {
                    // Check for range parameters (e.g. storage_min, storage_max)
                    const minVal = otherParams[`${def.key}_min`];
                    const maxVal = otherParams[`${def.key}_max`];

                    if (minVal !== undefined || maxVal !== undefined) {
                        queryObj[attrPath] = {};
                        if (minVal !== undefined && minVal !== "") queryObj[attrPath].$gte = Number(minVal);
                        if (maxVal !== undefined && maxVal !== "") queryObj[attrPath].$lte = Number(maxVal);
                    } else {
                        // Exact value or set of discrete choices
                        const values = Array.isArray(paramVal)
                            ? paramVal.map(Number)
                            : paramVal.toString().split(",").map((s) => Number(s.trim()));
                        queryObj[attrPath] = { $in: values };
                    }
                    break;
                }

                case "bool": {
                    if (paramVal === "true" || paramVal === true) queryObj[attrPath] = true;
                    else if (paramVal === "false" || paramVal === false) queryObj[attrPath] = false;
                    break;
                }
            }
        });
    }

    return queryObj;
}

module.exports = { buildMongoQuery };