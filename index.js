const express = require('express');
const path = require('path');

const app = express();
const port = 3000; // You can change the port if needed

app.use(express.static(__dirname));

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});