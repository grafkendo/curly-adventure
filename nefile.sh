#!/bin/bash

# Install Node.js and npm
sudo apt update
sudo apt install -y nodejs npm

# Create a new directory for the application
mkdir my-express-app
cd my-express-app

# Initialize a new Node.js project
npm init -y

# Install the Express middleware
npm install express

# Create a new file index.js with a basic Express application
echo "const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, () => {
  console.log('Server listening on port 3000');
});" > index.js

# Start the application
node index.js
