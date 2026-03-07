import { describe, it, expect } from 'vitest';
import { buildApp } from '../app.js';

describe('GET /health', () => {
    it('should return 200 with status ok and a timestamp', async () => {
        const app = await buildApp();

        const response = await app.inject({
            method: 'GET',
            url: '/health',
        });

        expect(response.statusCode).toBe(200);

        const body = JSON.parse(response.body);
        expect(body.success).toBe(true);
        expect(body.data.status).toBe('ok');
        expect(body.data.timestamp).toBeDefined();

        // Verify the timestamp is a valid ISO string
        expect(new Date(body.data.timestamp).toISOString()).toBe(body.data.timestamp);

        await app.close();
    });
});
