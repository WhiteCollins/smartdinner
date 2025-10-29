const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');

// Rutas de menú
router.get('/', menuController.getAll.bind(menuController));
router.get('/categories', menuController.getCategories.bind(menuController));
router.get('/popular', menuController.getPopular.bind(menuController));
router.get('/search/:term', menuController.search.bind(menuController));
router.get('/category/:category', menuController.getByCategory.bind(menuController));
router.get('/:id', menuController.getById.bind(menuController));
router.post('/', menuController.create.bind(menuController));
router.put('/:id', menuController.update.bind(menuController));
router.patch('/:id/availability', menuController.updateAvailability.bind(menuController));
router.patch('/:id/price', menuController.updatePrice.bind(menuController));
router.delete('/:id', menuController.delete.bind(menuController));

module.exports = router;
