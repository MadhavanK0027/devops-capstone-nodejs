const express = require("express");

const app = express();

const PORT = 3000;

app.get("/", (req, res) => {
    res.send(`
        <html>
        <head>
            <title>DevOps Capstone</title>
        </head>
        <body>
            <h1>DevOps Capstone Project</h1>
            <h2>Node.js Application is Running Successfully!</h2>
            <p>GitHub → Jenkins → Docker → AWS EC2</p>
        </body>
        </html>
    `);
});

app.get("/health", (req, res) => {
    res.json({
        status: "UP",
        application: "DevOps Capstone Node.js App"
    });
});

app.listen(PORT, () => {
    console.log(`Application running on port ${PORT}`);
});