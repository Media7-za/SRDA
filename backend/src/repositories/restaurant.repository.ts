// backend/src/repositories/restaurant.repository.ts
import { prisma } from "./base.repository";

export async function findAllRestaurants() {
    return prisma.restaurant.findMany({
        where: { isActive: true },
    });
}
