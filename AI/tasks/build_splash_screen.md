# 1. Task Metadata

## Task Name
Build Splash Screen

## File Path
`/ai/tasks/build_splash_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the initial loading/splash screen that visually engages the user while the application checks for an existing authentication session and hydrates critical initial state (e.g., fetching the restaurant configuration).

---

# 3. Business Context

The splash screen is the very first impression of the brand. It needs to be fast, visually appealing (incorporating the restaurant's logo/colors), and seamlessly transition into the main application once data is ready.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- Basic Next.js setup must be complete.
- App-wide state management (e.g., Zustand/React Query) initialized.

---

# 6. Scope

## In Scope
- Create the `/app/page.tsx` (or a dedicated splash route if using a mobile-app paradigm on web).
- Implement a visually pleasing loading animation or logo display using Tailwind CSS.
- Check for existing authentication tokens in local storage/cookies.
- Automatically redirect the user to the `/menu` (Home Dashboard) once initialization is complete.

## Out of Scope
- Actually building the Menu screen.

---

# 7. Inputs
- Brand assets (Logo, primary colors).

---

# 8. Required Outputs
- `SplashScreen` component.
- App initialization hook (e.g., `useAppBootstrap`).

---

# 9. Acceptance Criteria
- Screen displays immediately on load.
- No flickering or layout shifts.
- Redirects to `/menu` smoothly once data/auth states are confirmed.

---

# 10. Implementation Rules
- Keep the component extremely lightweight so it renders instantly.
- Avoid heavy imports on this specific route.

---

# 11. API / Data Contracts
None.

---

# 12. Edge Cases
- Network timeout during initial bootstrap (should display a graceful "Retry" or offline message instead of spinning forever).

---

# 13. Testing Requirements
- Component test verifying rendering.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Publicly accessible.

---

# 16. Performance Requirements
- Must achieve near-instant First Contentful Paint (FCP).

---

# 17. Deliverable Format
- Next.js page component and associated hooks.

---

# 18. Completion Checklist
- [ ] Fast FCP achieved
- [ ] Auth state checked
- [ ] Smooth transition to menu

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Ensure styling uses Tailwind CSS and matches the overarching brand aesthetic.

---
End of File
