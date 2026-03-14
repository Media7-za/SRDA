import type { FastifyInstance } from 'fastify';
import { AdminOrdersController } from '../controllers/admin-orders.controller.js';

export function registerAdminOrdersRoutes(app: FastifyInstance) {
    app.get('/api/orders/board', AdminOrdersController.getBoard);
    app.patch('/api/orders/:id/status', AdminOrdersController.updateStatus);
    app.post('/api/orders/:id/assign-driver', AdminOrdersController.assignDriver);
}
