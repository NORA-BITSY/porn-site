const express = require('express');
const hbs = require('hbs');
const bodyParser = require('body-parser');
const axios = require('axios');
const mongoose = require('mongoose');
const methodOverride = require('method-override');
const ip = require('ip');
require('dotenv').config();

// Import routes
const pornstars = require('./server/routes/pornstar');
const tags = require('./server/routes/tag');
const basics = require('./server/routes/basic');
const actions = require('./server/routes/actions');

// Import models
const { Video } = require('./server/models/video');

const app = express();
const port = process.env.PORT || 3000;

// Mongoose connection
mongoose.Promise = global.Promise;
const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/ultimate-porn-space';
mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Connected to MongoDB');
}).catch(err => {
    console.error('Failed to connect to MongoDB', err);
});

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(methodOverride('_method'));
app.set('view engine', 'hbs');
app.use(express.static(__dirname + '/public'));
hbs.registerPartials(__dirname + '/views/partials');

// Routes
app.use('/tags', tags);
app.use('/stars', pornstars);
app.use('/action', actions);
app.use('/', basics);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).render('error', {
        error_code: 500,
        error_message: 'Something went wrong on our end.'
    });
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
