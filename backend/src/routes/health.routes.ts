import type { FastifyInstance } from 'fastify';
import { healthCheck } from '../controllers/health.controller.js';

export function registerHealthRoutes(app: FastifyInstance) {
    app.get('/health', healthCheck);
}
