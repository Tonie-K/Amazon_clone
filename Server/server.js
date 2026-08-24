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

app.listen(port, () => {
    console.log(`server is running on port ${port}`);
});