const categoryDefs = require("../config/categoryDefs");

/**
 * Parses request query parameters against category definitions and returns a MongoDB query object.
 * @param {Object} queryParams - The request query parameters.
 * @param {Object} options - Options containing an `exclude` array of field keys to ignore.
 */
function buildMongoQuery(queryParams, options = {}) {
    const excludes = options.exclude || [];
    const { category, minPrice, maxPrice, minRating, ...otherParams } = queryParams;
    let queryObj = {};

    // 1. Top-level category filter
    let activeCategoryDef = null;
    if (category && !excludes.includes("category")) {
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
    } else if (category) {
        // Resolve category definition even if category parameter is excluded from queryObj
        const trimmedCategory = category.trim();
        const categoryKey = Object.keys(categoryDefs).find(
            (k) => k.toLowerCase() === trimmedCategory.toLowerCase()
        );
        if (categoryKey) {
            activeCategoryDef = categoryDefs[categoryKey];
        }
    }

    // 2. Top-level Price Range
    if (!excludes.includes("price") && (minPrice !== undefined || maxPrice !== undefined)) {
        queryObj.price = {};
        if (minPrice !== undefined && minPrice !== "") queryObj.price.$gte = Number(minPrice);
        if (maxPrice !== undefined && maxPrice !== "") queryObj.price.$lte = Number(maxPrice);
    }

    // 3. Top-level Rating
    if (!excludes.includes("rating") && minRating !== undefined && minRating !== "") {
        queryObj.rating = { $gte: Number(minRating) };
    }

    // 4. Attribute Whitelisting & Condition Building
    if (activeCategoryDef) {
        activeCategoryDef.forEach((def) => {
            if (excludes.includes(def.key)) return;

            const paramVal = otherParams[def.key];
            if (paramVal === undefined || paramVal === null || paramVal === "") return;

            const attrPath = `attributes.${def.key}`;

            switch (def.type) {
                case "enum": {
                    const values = Array.isArray(paramVal)
                        ? paramVal
                        : paramVal.toString().split(",").map((s) => s.trim());
                    queryObj[attrPath] = { $in: values };
                    break;
                }

                case "number": {
                    const minVal = otherParams[`${def.key}_min`];
                    const maxVal = otherParams[`${def.key}_max`];

                    if (minVal !== undefined || maxVal !== undefined) {
                        queryObj[attrPath] = {};
                        if (minVal !== undefined && minVal !== "") queryObj[attrPath].$gte = Number(minVal);
                        if (maxVal !== undefined && maxVal !== "") queryObj[attrPath].$lte = Number(maxVal);
                    } else {
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