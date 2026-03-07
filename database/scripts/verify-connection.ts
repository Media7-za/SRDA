/**
 * verify-connection.ts
 * ─────────────────────────────────────────────────────────────────
 * Verifies that the Prisma Client can connect to the PostgreSQL
 * database. Exits with code 0 on success, 1 on failure.
 *
 * Usage:  pnpm run db:verify
 * ─────────────────────────────────────────────────────────────────
 */

import { prisma } from '../src/client.js';

async function main() {
    const maskedUrl = (process.env['DATABASE_URL'] ?? '')
        .replace(/:([^@]+)@/, ':****@');

    console.log(`\n🔌 Connecting to: ${maskedUrl}\n`);

    try {
        // Attempt a raw query to verify the connection
        const result = await prisma.$queryRaw<[{ connected: number }]>`SELECT 1 AS connected`;

        if (result[0]?.connected === 1) {
            console.log('✅ Database connection successful.');
        } else {
            throw new Error('Unexpected query result');
        }

        // Count tables to verify migration state
        const tables = await prisma.$queryRaw<{ table_name: string }[]>`
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_type = 'BASE TABLE'
              AND table_name != '_prisma_migrations'
            ORDER BY table_name
        `;

        console.log(`📊 Found ${tables.length} tables in the database:`);
        for (const t of tables) {
            console.log(`   • ${t.table_name}`);
        }

        if (tables.length === 0) {
            console.warn('\n⚠️  No tables found — have you run the migration?');
            console.warn('   Run: pnpm run db:migrate:dev\n');
        } else {
            console.log('\n🎉 Database is ready for development.\n');
        }
    } catch (error) {
        console.error('❌ Database connection failed:\n');
        console.error(error instanceof Error ? error.message : error);
        console.error('\nTroubleshooting:');
        console.error('  1. Is PostgreSQL running?  →  docker compose up -d');
        console.error('  2. Is DATABASE_URL correct in database/.env ?');
        console.error('  3. Does the database exist?  →  Check docker compose logs db\n');
        process.exit(1);
    } finally {
        await prisma.$disconnect();
    }
}

main();
