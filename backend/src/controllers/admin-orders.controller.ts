import type { FastifyRequest, FastifyReply } from 'fastify';
import { AdminOrdersService } from '../services/admin-orders.service.js';
import { OrderStatus } from '@restaurant-direct/database';

export class AdminOrdersController {
    static async getBoard(request: FastifyRequest<{ Querystring: { restaurant_id: string } }>, reply: FastifyReply) {
        try {
            const { restaurant_id } = request.query;

            if (!restaurant_id) {
                return reply.code(400).send({ success: false, error: 'restaurant_id missing' });
            }

            // Note: In a real app we would validate the JWT and ensure the user's
            // restaurantId inside their token matches the requested one.
            const data = await AdminOrdersService.getBoard(restaurant_id);
            return reply.send({ success: true, data });
        } catch (error: any) {
            return reply.code(500).send({ success: false, error: error.message });
        }
    }

    static async updateStatus(request: FastifyRequest<{ Params: { id: string }, Body: { status: OrderStatus } }>, reply: FastifyReply) {
        try {
            const { id } = request.params;
            const { status } = request.body;
            // Mock restaurant scope validation for MVP API
            const restaurantId = 'mock_request_restaurant_id'; // In reality derived from JWT

            const data = await AdminOrdersService.updateStatus(restaurantId, id, status);
            return reply.send({ success: true, data });
        } catch (error: any) {
            if (error.message.includes('not found')) {
                return reply.code(404).send({ success: false, error: error.message });
            }
            if (error.message.includes('already complete')) {
                return reply.code(409).send({ success: false, error: error.message });
            }
            return reply.code(422).send({ success: false, error: error.message });
        }
    }

    static async assignDriver(request: FastifyRequest<{ Params: { id: string }, Body: { driverId: string } }>, reply: FastifyReply) {
        try {
            const { id } = request.params;
            const { driverId } = request.body;
            const restaurantId = 'mock_request_restaurant_id'; // Built dynamically in reality

            if (!driverId) {
                return reply.code(422).send({ success: false, error: 'Driver required' });
            }

            const data = await AdminOrdersService.assignDriver(restaurantId, id, driverId);
            return reply.send({ success: true, data });
        } catch (error: any) {
            return reply.code(422).send({ success: false, error: error.message });
        }
    }
}
