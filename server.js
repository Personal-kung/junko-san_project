const express = require("express");
const bodyParser = require("body-parser");
const fs = require("fs");
const path = require("path");
const cors = require("cors");

const app = express();
const PORT = 3000;

const DATA_FILE = path.join(__dirname, "data.json");
const BOOKINGS_FILE = path.join(__dirname, "bookings.json");

app.use(bodyParser.json());
app.use(cors());
app.use(express.static(path.join(__dirname, "public")));

// Ensure bookings.json exists
if (!fs.existsSync(BOOKINGS_FILE)) {
    fs.writeFileSync(BOOKINGS_FILE, JSON.stringify([]));
}

// API: Get site data
app.get("/api/data", (req, res) => {
    const data = JSON.parse(fs.readFileSync(DATA_FILE, "utf-8"));
    res.json(data);
});

// API: Update site data
app.post("/api/data", (req, res) => {
    fs.writeFileSync(DATA_FILE, JSON.stringify(req.body, null, 2));
    res.json({ success: true, message: "Site data updated!" });
});

// API: Get bookings
app.get("/api/bookings", (req, res) => {
    const bookings = JSON.parse(fs.readFileSync(BOOKINGS_FILE, "utf-8"));
    res.json(bookings);
});

// API: Add booking
app.post("/api/bookings", (req, res) => {
    const bookings = JSON.parse(fs.readFileSync(BOOKINGS_FILE, "utf-8"));
    bookings.push(req.body);
    fs.writeFileSync(BOOKINGS_FILE, JSON.stringify(bookings, null, 2));
    res.json({ success: true, message: "Booking saved!" });
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});