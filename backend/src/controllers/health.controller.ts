import type { FastifyRequest, FastifyReply } from 'fastify';
import type { HealthCheckResponse, ApiSuccessResponse } from '@restaurant-direct/types';

/**
 * Health check controller.
 * Returns a simple 200 OK with a timestamp to prove the server is alive.
 */
export async function healthCheck(
    _request: FastifyRequest,
    reply: FastifyReply,
): Promise<ApiSuccessResponse<HealthCheckResponse>> {
    const response: ApiSuccessResponse<HealthCheckResponse> = {
        success: true,
        data: {
            status: 'ok',
            timestamp: new Date().toISOString(),
        },
    };

    return reply.status(200).send(response);
}
