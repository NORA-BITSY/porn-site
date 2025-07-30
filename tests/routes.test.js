const request = require('supertest');
const express = require('express');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');

// Import routes
const actions = require('../server/routes/actions');
const basics = require('../server/routes/basic');

// Create test app
const createTestApp = () => {
  const app = express();
  
  // Middleware
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(methodOverride('_method'));
  
  // Routes
  app.use('/action', actions);
  app.use('/', basics);
  
  return app;
};

describe('Basic Routes', () => {
  let app;
  
  beforeEach(() => {
    app = createTestApp();
  });

  describe('GET /about', () => {
    it('should return about page', async () => {
      const response = await request(app)
        .get('/about')
        .expect(200);
      
      // Since we're using handlebars rendering, we'd need to mock that
      // For now, just test that the route doesn't crash
    });
  });

  describe('GET /favorites', () => {
    it('should return favorites page', async () => {
      const response = await request(app)
        .get('/favorites')
        .expect(200);
    });
  });

  describe('GET /', () => {
    it('should handle search query', async () => {
      // Mock axios to prevent actual API calls
      const axios = require('axios');
      jest.mock('axios');
      
      const mockResponse = {
        data: {
          count: 1,
          videos: [
            {
              video_id: '123',
              title: 'Test Video',
              thumb: 'test.jpg'
            }
          ]
        }
      };
      
      axios.get.mockResolvedValue(mockResponse);
      
      const response = await request(app)
        .get('/?search=test')
        .expect(200);
    });
  });
});

describe('Action Routes', () => {
  let app;
  
  beforeEach(() => {
    app = createTestApp();
  });

  describe('GET /action/save/:id', () => {
    it('should handle video save request', async () => {
      // Mock axios for RedTube API
      const axios = require('axios');
      const mockResponse = {
        data: {
          video: {
            video_id: '123',
            title: 'Test Video',
            thumb: 'test.jpg'
          }
        }
      };
      
      axios.get.mockResolvedValue(mockResponse);
      
      const response = await request(app)
        .get('/action/save/123')
        .expect(302); // Expect redirect
    });
  });
});

describe('Video Model', () => {
  const { Video } = require('../server/models/video');
  
  it('should create a video document', async () => {
    const videoData = {
      video_id: '123',
      title: 'Test Video',
      ip: '127.0.0.1',
      thumb: 'test.jpg'
    };
    
    const video = new Video(videoData);
    const savedVideo = await video.save();
    
    expect(savedVideo.video_id).toBe('123');
    expect(savedVideo.title).toBe('Test Video');
    expect(savedVideo.ip).toBe('127.0.0.1');
  });
  
  it('should validate required fields', async () => {
    const video = new Video({});
    
    let error;
    try {
      await video.save();
    } catch (err) {
      error = err;
    }
    
    expect(error).toBeDefined();
  });
});
