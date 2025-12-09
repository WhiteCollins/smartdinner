// Vercel serverless function entry point
try {
  const app = require('../backend/src/app');
  
  if (!app) {
    throw new Error('Backend app not found or did not export properly');
  }
  
  module.exports = app;
} catch (error) {
  console.error('Error loading backend app:', error);
  throw error;
}
