const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Rutas de usuarios
router.get('/', userController.getAll.bind(userController));
router.get('/email/:email', userController.getByEmail.bind(userController));
router.get('/:id', userController.getById.bind(userController));
router.get('/:id/profile', userController.getProfile.bind(userController));
router.put('/:id', userController.update.bind(userController));
router.delete('/:id', userController.delete.bind(userController));

module.exports = router;
