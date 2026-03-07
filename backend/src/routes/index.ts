import type { FastifyInstance } from 'fastify';
import { registerHealthRoutes } from './health.routes.js';

/**
 * Central route registry.
 * All feature route modules are registered here.
 */
export function registerRoutes(app: FastifyInstance) {
    registerHealthRoutes(app);
}
