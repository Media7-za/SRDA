// backend/src/repositories/__tests__/wiring.test.ts
import { describe, it, expect } from 'vitest';
import { findAllRestaurants } from '../restaurant.repository';
import { prisma } from '../base.repository';

describe('End-to-end Wiring Verification', () => {
    it('base repository exposes the prisma singleton', () => {
        expect(prisma).toBeDefined();
        expect(typeof prisma.restaurant.findMany).toBe('function');
    });

    it('restaurant repository can execute a query without error', async () => {
        // Since we have no seed data yet, this should return an empty array, 
        // but it proves the connection works.
        const restaurants = await findAllRestaurants();
        expect(Array.isArray(restaurants)).toBe(true);
    });
});
