const categoryDefs = {
    "Laptops": [
        { key: "processor", label: "Processor", type: "enum", unit: "", filterable: true },
        { key: "ram", label: "RAM", type: "number", unit: "GB", filterable: true },
        { key: "storage", label: "Storage", type: "number", unit: "GB", filterable: true },
        { key: "screenSize", label: "Screen Size", type: "number", unit: "inches", filterable: true },
        { key: "touchscreen", label: "Touchscreen", type: "bool", unit: "", filterable: false }
    ],
    "Mouse": [
        { key: "connectivity", label: "Connectivity", type: "enum", unit: "", filterable: true },
        { key: "dpi", label: "DPI", type: "number", unit: "DPI", filterable: true },
        { key: "buttons", label: "Buttons", type: "number", unit: "", filterable: false },
        { key: "rgb", label: "RGB Lighting", type: "bool", unit: "", filterable: true }
    ],
    "Controllers": [
        { key: "platform", label: "Platform", type: "enum", unit: "", filterable: true },
        { key: "wireless", label: "Wireless", type: "bool", unit: "", filterable: true },
        { key: "hapticFeedback", label: "Haptic Feedback", type: "bool", unit: "", filterable: false },
        { key: "color", label: "Color", type: "enum", unit: "", filterable: false }
    ],
    "Keyboards": [
        { key: "switchType", label: "Switch Type", type: "enum", unit: "", filterable: true },
        { key: "backlight", label: "Backlight", type: "enum", unit: "", filterable: true },
        { key: "wireless", label: "Wireless", type: "bool", unit: "", filterable: true },
        { key: "layout", label: "Layout", type: "enum", unit: "", filterable: false }
    ],
    "Perfumes": [
        { key: "volume", label: "Volume", type: "number", unit: "ml", filterable: false },
        { key: "scentType", label: "Scent Family", type: "enum", unit: "", filterable: true },
        { key: "concentration", label: "Concentration", type: "enum", unit: "", filterable: true }
    ],
    "Bottles": [
        { key: "material", label: "Material", type: "enum", unit: "", filterable: true },
        { key: "capacity", label: "Capacity", type: "number", unit: "ml", filterable: true },
        { key: "insulated", label: "Is Insulated", type: "bool", unit: "", filterable: true },
        { key: "bpaFree", label: "BPA Free", type: "bool", unit: "", filterable: false }
    ],
    "Shoes": [
        { key: "type", label: "Type", type: "enum", unit: "", filterable: true },
        { key: "sizeUK", label: "UK Size", type: "number", unit: "UK", filterable: true },
        { key: "material", label: "Material", type: "enum", unit: "", filterable: false },
        { key: "closure", label: "Closure", type: "enum", unit: "", filterable: false }
    ],
    "Shirts": [
        { key: "fabric", label: "Fabric", type: "enum", unit: "", filterable: true },
        { key: "fit", label: "Fit Type", type: "enum", unit: "", filterable: true },
        { key: "sleeve", label: "Sleeve", type: "enum", unit: "", filterable: true },
        { key: "pattern", label: "Pattern", type: "enum", unit: "", filterable: false }
    ],
    "Stand Fans": [
        { key: "power", label: "Power Consumption", type: "number", unit: "W", filterable: true },
        { key: "speeds", label: "Speed Settings", type: "number", unit: "", filterable: false },
        { key: "remoteControl", label: "Remote Included", type: "bool", unit: "", filterable: true },
        { key: "heightAdjustable", label: "Height Adjustable", type: "bool", unit: "", filterable: false }
    ],
    "Bags": [
        { key: "capacity", label: "Capacity", type: "number", unit: "L", filterable: true },
        { key: "laptopCompartment", label: "Laptop Pocket", type: "bool", unit: "", filterable: true },
        { key: "waterResistant", label: "Water Resistant", type: "bool", unit: "", filterable: true },
        { key: "material", label: "Material", type: "enum", unit: "", filterable: false }
    ]
};

module.exports = categoryDefs;