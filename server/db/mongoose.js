var mongoose = require('mongoose');
require('dotenv').config();

mongoose.Promise = global.Promise;

// Use environment variable for MongoDB connection
const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/ultimate-porn-space';
mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

module.exports = {mongoose};