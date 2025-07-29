# Ultimate Porn Space

**Ultimate Porn Space** is a web application designed to provide a comprehensive and user-friendly experience for browsing and viewing adult video content. The application features a clean and intuitive interface, allowing users to easily discover, search, and organize a vast catalog of videos.

## Overview

This project is a full-stack web application built with Node.js, Express, and MongoDB. The front-end is rendered using Handlebars.js, providing a classic server-side rendered experience. The application is designed to be a feature-rich platform for adult content, with a focus on user experience and content organization.

## Key Features

-   **Extensive Video Catalog**: Browse a large collection of videos with pagination.
-   **Pornstar and Tag Indexes**: Discover content through dedicated pages for pornstars and tags.
-   **Favorites System**: Save videos to a personal list for later viewing.
-   **Advanced Search**: Search for videos based on keywords and other criteria.
-   **Responsive Design**: The application is designed to be accessible on both desktop and mobile devices.

## Tech Stack

-   **Backend**: Node.js, Express.js
-   **Database**: MongoDB with Mongoose
-   **Templating Engine**: Handlebars.js (with `hbs` for Express integration)
-   **Styling**: CSS with a simple, clean design
-   **Dependencies**:
    -   `axios`: For making HTTP requests to external APIs.
    -   `body-parser`: For parsing request bodies.
    -   `dotenv`: For managing environment variables.
    -   `lodash`: For utility functions.
    -   `method-override`: For using HTTP verbs like PUT or DELETE in forms.

## File Structure

```
.
├── .babelrc
├── .gitignore
├── README.md
├── package.json
├── public/
│   ├── css/
│   ├── images/
│   └── js/
├── server/
│   ├── db/
│   │   └── mongoose.js
│   ├── models/
│   │   └── video.js
│   └── routes/
│       ├── actions.js
│       └── basic.js
├── server.js
└── views/
    ├── partials/
    ... (and other .hbs files)
```

-   `server.js`: The main entry point for the application.
-   `server/db/mongoose.js`: Configures the connection to the MongoDB database.
-   `server/models/`: Contains the Mongoose data models.
-   `server/routes/`: Defines the application's routes and API endpoints.
-   `public/`: Contains static assets like CSS, JavaScript, and images.
-   `views/`: Contains the Handlebars templates for the application's pages.

## Installation and Setup

To run this project locally, you will need Node.js and MongoDB installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/NORA-BITSY/Adult.git
    cd porn-site
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    ```

3.  **Set up environment variables:**
    Create a `.env` file in the root of the project and add the following variables:
    ```
    MONGODB_URI=mongodb://localhost:27017/ultimate-porn-space
    PORT=3000
    ```

4.  **Start the MongoDB server:**
    Ensure that your local MongoDB server is running.

## Running the Application

To start the application, run the following command:

```bash
npm start
```

The application will be available at `http://localhost:3000`.

## User Guide

-   **Home Page**: The main page displays a paginated catalog of videos.
-   **Video Page**: Click on a video to view it and see its details, including tags and pornstars.
-   **Favorites**: Click the "Save to Favorites" button on a video page to add it to your list. You can view your favorites from the "Favorites" page in the navigation bar.
-   **Search**: Use the search bar to find videos by title, tags, or other keywords.

## API Integration

The application currently uses the Redtube API to source its video content. There are plans to integrate the [Pornhub API](https://www.npmjs.com/package/pornhub-api) to expand the content library and add more features.

## Troubleshooting

-   **Database Connection Issues**: Ensure that your MongoDB server is running and that the `MONGODB_URI` in your `.env` file is correct.
-   **Missing Dependencies**: If you encounter errors related to missing modules, run `npm install` to ensure all dependencies are installed.
-   **Server Crashes**: Check the console for error messages. Common issues include problems with API requests or database queries.

## Contributing

Contributions are welcome! If you would like to contribute to the project, please follow these steps:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Make your changes and commit them with descriptive messages.
4.  Push your changes to your fork.
5.  Open a pull request to the main repository.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
