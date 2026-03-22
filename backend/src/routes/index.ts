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

    // --- Mock Driver Auth for Mobile Testing ---
    app.post('/api/auth/driver/login', async (request, reply) => {
        const { email, password } = request.body as any;
        app.log.info({ email }, 'Driver login attempt');

        // Match seed data: driver1@example.com / hashed_pw (using password as 'password' for test)
        if (email.startsWith('driver') && (password === 'password' || password === 'hashed_pw')) {
            return reply.send({
                success: true,
                data: {
                    token: "mock-jwt-token-for-testing",
                    user: {
                        id: email.includes('1') ? 'driver_1' : 'driver_2',
                        email: email,
                        role: 'driver'
                    }
                }
            });
        }

        return reply.code(401).send({
            success: false,
            error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' }
        });
    });
}
