# Database — `@restaurant-direct/database`

This package owns the Prisma schema, migrations, and the shared database client.

## Prerequisites

- **Docker** (recommended) — for local PostgreSQL
- Or: PostgreSQL 15+ installed locally (Postgres.app / Homebrew)

## Quick Start

From the **project root**:

```bash
# 1. Start PostgreSQL
pnpm db:up

# 2. Install dependencies (if not already done)
pnpm install

# 3. Run the first migration
pnpm db:migrate

# 4. Verify the connection
pnpm db:verify
```

## Available Scripts

| Script | Description |
|--------|-------------|
| `pnpm db:up` | Start PostgreSQL via Docker Compose |
| `pnpm db:down` | Stop PostgreSQL |
| `pnpm db:migrate` | Create/apply migrations (`prisma migrate dev`) |
| `pnpm db:generate` | Regenerate Prisma Client |
| `pnpm db:verify` | Verify database connection and table state |
| `pnpm db:studio` | Open Prisma Studio (GUI) |

All commands above run from the **project root**. You can also run them from `database/` using the `db:*` script names directly.

## Database Configuration

Connection string is in `database/.env`:

```
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/restaurant_direct_dev?schema=public"
```

> ⚠️ These credentials are for **local development only**. Production must use secure, unique credentials.

## Changing the Port

If port 5432 is in use, set `DB_PORT` in your root `.env`:

```
DB_PORT=5433
```

Then restart: `pnpm db:down && pnpm db:up`

## Resetting the Database

To destroy all data and re-run migrations:

```bash
docker compose down -v
pnpm db:up
pnpm db:migrate
```

## Architecture

```
database/
  prisma/
    schema.prisma        ← Schema source of truth
    migrations/          ← Generated migration SQL
  scripts/
    verify-connection.ts ← Connection health check
  src/
    client.ts            ← Prisma Client singleton
```

The backend imports the client via:

```typescript
import { prisma } from "@restaurant-direct/database/client";
```
