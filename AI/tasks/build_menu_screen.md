# 1. Task Metadata

## Task Name
Build Menu Screen

## File Path
`/ai/tasks/build_menu_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the main Home Dashboard/Menu screen where the customer browses categories and views items available for order.

---

# 3. Business Context

This is the core discovery interface. It must be highly responsive, visually appetizing, and easy to navigate (e.g., scrolling categories).

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/frontend_agent.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- `create_menu_fetch_api.md` (Backend API must be ready).
- `build_splash_screen.md` (Navigation flow).

---

# 6. Scope

## In Scope
- Create `/app/menu/page.tsx`.
- Integrate React Query to fetch `GET /restaurants/:id/menu`.
- Build a sticky/horizontal Category navigation bar.
- Build the Menu Item List (grouped by category).
- Build the `MenuItemCard` component displaying image, title, description, and price.
- Implement a floating "View Cart" FAB (Floating Action Button) if the cart has items.

## Out of Scope
- The detailed item customization modal (handled in the next task).

---

# 7. Inputs
- Menu API JSON Response.
- Global Cart state (Zustand).

---

# 8. Required Outputs
- `MenuPage` component.
- `CategoryNav` component.
- `MenuItemCard` component.
- `useMenu` React Query hook mapping to the service layer.

---

# 9. Acceptance Criteria
- Menu data is fetched and cached seamlessly.
- Categories can be clicked to smoothly scroll to the respective section.
- "View Cart" button appears dynamically based on Zustand store state.
- Loading skeletons are displayed while data is fetching.

---

# 10. Implementation Rules
- Follow strictly modern aesthetics: use Shadcn/Tailwind for clean UI.
- Use `useQuery` for fetching. Do NOT fetch data directly inside `useEffect` in the component.

---

# 11. API / Data Contracts
Consumes `GET /restaurants/:restaurantId/menu` returning the nested category/items structure.

---

# 12. Edge Cases
- Restaurant has 0 active items.
- API is offline.

---

# 13. Testing Requirements
- Component tests for `MenuItemCard`.
- Integration tests ensuring clicking a category scrolls the view.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Publicly accessible.

---

# 16. Performance Requirements
- Optimize image loading using `next/image`.
- Ensure React Query caches the menu to prevent re-fetching on back-navigation.

---

# 17. Deliverable Format
Next.js page, components, and hooks.

---

# 18. Completion Checklist
- [ ] React Query implemented
- [ ] Category scroll sync working
- [ ] View Cart FAB dynamic

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Mobile responsiveness is critical here. It must feel like a native app on a phone browser.

---
End of File
