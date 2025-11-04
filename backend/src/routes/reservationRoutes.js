const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');

// Rutas de reservaciones
router.get('/', reservationController.getAll.bind(reservationController));
router.get('/stats', reservationController.getStats.bind(reservationController));
router.get('/user/:userId', reservationController.getByUser.bind(reservationController));
router.get('/date/:date', reservationController.getByDate.bind(reservationController));
router.get('/status/:status', reservationController.getByStatus.bind(reservationController));
router.get('/:id', reservationController.getById.bind(reservationController));
router.post('/', reservationController.create.bind(reservationController));
router.put('/:id', reservationController.update.bind(reservationController));
router.patch('/:id/status', reservationController.updateStatus.bind(reservationController));
router.post('/:id/confirm', reservationController.confirm.bind(reservationController));
router.post('/:id/cancel', reservationController.cancel.bind(reservationController));
router.delete('/:id', reservationController.delete.bind(reservationController));

module.exports = router;
