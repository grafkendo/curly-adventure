const express = require('express');
const mongoose = require('mongoose');

// Connect to MongoDB
const connectionString = 'mongodb://localhost:27017/my_database';

// Create a Mongoose connection
const mongoClient = new mongoose.MongoClient(connectionString);

// Create a Mongoose model for the `users` collection
const User = mongoose.model('User', {
  name: String,
  email: String,
  password: String,
});

// Create an Express app
const app = express();

// Create a route to create a new user
app.post('/users', async (req, res) => {
  // Create a new user
  const user = new User({
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
  });

  // Save the user to the database
  try {
    await user.save();
    res.send('User created successfully');
  } catch (err) {
    res.send(err);
  }
});

// Create a route to get all users
app.get('/users', async (req, res) => {
  // Get all users from the database
  const users = await User.find();

  // Send the users to the client
  res.json(users);
});

// Start the server
app.listen(3000, () => {
  console.log('App is running on port 3000');
});
