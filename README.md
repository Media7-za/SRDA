# Restaurant Direct

> Direct restaurant ordering & delivery platform — no marketplace fees.

## Overview

Restaurant Direct enables restaurants to accept direct delivery and pickup orders through their own branded interface, eliminating 20–35% marketplace commissions.

## Tech Stack

| Layer        | Technology                              |
| ------------ | --------------------------------------- |
| Frontend Web | Next.js · React · Tailwind CSS          |
| Backend API  | Node.js · Fastify · TypeScript          |
| Database     | PostgreSQL · Prisma ORM                 |
| Mobile       | Flutter (separate repository)           |
| Payments     | Stripe                                  |
| Auth         | JWT + bcrypt                            |

## Monorepo Structure

```
/apps
  /web              ← Next.js web application
/backend
  /src
    /config          ← Environment & app configuration
    /controllers     ← HTTP request/response handling
    /services        ← Core business logic
    /repositories    ← Database access layer (Prisma)
    /routes          ← API endpoint definitions
    /middlewares     ← Auth, validation, error handling
    /utils           ← Shared helper functions
/database
  /schema            ← Prisma schema definitions
  /migrations        ← Auto-generated DB migrations
/packages
  /types             ← Shared TypeScript types
  /config            ← Shared ESLint, Prettier, TS configs
/docs                ← Project documentation
/AI                  ← AI context & task documents
```

## Prerequisites

- **Node.js** ≥ 20.x (see `.nvmrc`)
- **pnpm** ≥ 9.x

## Getting Started

```bash
# 1. Install dependencies
pnpm install

# 2. Copy environment variables
cp .env.example .env

# 3. Start all dev servers (frontend + backend)
pnpm dev

# Or start individually:
pnpm dev:web       # Frontend on http://localhost:3000
pnpm dev:backend   # Backend  on http://localhost:3001
```

## Available Scripts

| Script          | Description                            |
| --------------- | -------------------------------------- |
| `pnpm dev`      | Start all dev servers in parallel      |
| `pnpm dev:web`  | Start only the Next.js frontend        |
| `pnpm dev:backend` | Start only the Fastify backend      |
| `pnpm build`    | Build all packages for production      |
| `pnpm lint`     | Run ESLint across all packages         |
| `pnpm format`   | Format code with Prettier              |
| `pnpm test`     | Run all test suites                    |

## API Health Check

Once the backend is running, verify it responds:

```bash
curl http://localhost:3001/health
# → {"success":true,"data":{"status":"ok","timestamp":"..."}}
```

## Architecture

See [AI/architecture.md](./AI/architecture.md) for the full architecture specification.

**Key rules:**
- **Controller → Service → Repository** layered pattern (strictly enforced)
- Services contain business logic; Controllers stay thin
- Only Repositories may access the database (via Prisma)
- Shared types live in `packages/types` — frontend and backend import from there

## Documentation

- [Product Requirements](./docs/PRD_Core.md)
- [Architecture Specification](./AI/architecture.md)
- [Agent Rules](./AI/agent_rules.md)
- [Implementation Decisions](./AI/implementation_decisions.md)

## License

Private — All rights reserved.
