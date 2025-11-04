const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');

// Rutas de inventario
router.get('/', inventoryController.getAll.bind(inventoryController));
router.get('/low-stock', inventoryController.getLowStock.bind(inventoryController));
router.get('/out-of-stock', inventoryController.getOutOfStock.bind(inventoryController));
router.get('/purchase-order', inventoryController.generatePurchaseOrder.bind(inventoryController));
router.get('/stats', inventoryController.getStats.bind(inventoryController));
router.get('/:id', inventoryController.getById.bind(inventoryController));
router.get('/:id/history', inventoryController.getHistory.bind(inventoryController));
router.post('/', inventoryController.create.bind(inventoryController));
router.post('/movement', inventoryController.recordMovement.bind(inventoryController));
router.put('/:id', inventoryController.update.bind(inventoryController));
router.patch('/:id/quantity', inventoryController.updateQuantity.bind(inventoryController));
router.delete('/:id', inventoryController.delete.bind(inventoryController));

module.exports = router;
