const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

const express = require("express"); // npm install express
const mongoose = require("mongoose"); // npm i mongoose

require("dotenv").config(); // Load Environment Variables. Make sure .env is in .gitignore. npm i dotenv

const port = process.env.PORT;

// Connect to MongoDB
mongoose
    .connect(process.env.MONGO_URI, {})
    .then(() => {
        console.log("Connected to MongoDB");
    })
    .catch((err) => {
        console.log("Error connecting to MongoDB: ", err);
    });

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

require("./models/user");
require("./models/product");
require("./models/order");

require("./routes/authRoutes")(app);
require("./routes/orderRoutes")(app);
require("./routes/productRoutes")(app);

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
});