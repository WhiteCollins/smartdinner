const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Rutas de órdenes
router.get('/', orderController.getAll.bind(orderController));
router.get('/active', orderController.getActive.bind(orderController));
router.get('/stats', orderController.getStats.bind(orderController));
router.get('/top-selling', orderController.getTopSelling.bind(orderController));
router.get('/user/:userId', orderController.getByUser.bind(orderController));
router.get('/status/:status', orderController.getByStatus.bind(orderController));
router.get('/:id', orderController.getById.bind(orderController));
router.post('/', orderController.create.bind(orderController));
router.put('/:id', orderController.update.bind(orderController));
router.patch('/:id/status', orderController.updateStatus.bind(orderController));
router.post('/:id/cancel', orderController.cancel.bind(orderController));
router.delete('/:id', orderController.delete.bind(orderController));

module.exports = router;
