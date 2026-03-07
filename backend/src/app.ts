import Fastify from 'fastify';
import cors from '@fastify/cors';
import { registerRoutes } from './routes/index.js';

export async function buildApp() {
    const isDevLogging =
        process.env.NODE_ENV !== 'production' && process.env.NODE_ENV !== 'test';

    const app = Fastify({
        logger: {
            level: process.env.NODE_ENV === 'test' ? 'silent' : 'info',
            transport: isDevLogging
                ? { target: 'pino-pretty', options: { colorize: true } }
                : undefined,
        },
    });

    // ── Plugins ──────────────────────────────────────────────────────
    await app.register(cors, {
        origin: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
    });

    // ── Routes ───────────────────────────────────────────────────────
    registerRoutes(app);

    return app;
}
