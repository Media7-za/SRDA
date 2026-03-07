/**
 * Services Layer
 *
 * This directory contains all business logic modules.
 * Services must:
 * - Contain all business rules and domain logic
 * - Call repositories for data access
 * - Call external providers (e.g., Stripe) when needed
 * - Throw domain-specific errors (never HTTP errors)
 * - Never import or reference HTTP-specific objects (req, res)
 * - Never write raw SQL
 */
