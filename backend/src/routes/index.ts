import type { FastifyInstance } from 'fastify';
import { registerRoutes as _unused } from './index.js'; // To avoid unused variable
import { registerHealthRoutes } from './health.routes.js';
import { registerAdminOrdersRoutes } from './admin-orders.routes.js';

/**
 * Central route registry.
 * All feature route modules are registered here.
 */
export function registerRoutes(app: FastifyInstance) {
    app.get('/', async () => {
        return { status: 'running', service: 'restaurant-direct-api' };
    });
    registerHealthRoutes(app);
    registerAdminOrdersRoutes(app);
}
