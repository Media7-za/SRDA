# 1. Task Metadata

## Task Name
Build Item Detail Screen

## File Path
`/ai/tasks/build_item_detail_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the Item Customization view (either a dedicated route `/app/menu/item/[id]` or a highly polished UI Modal/Drawer) allowing users to select options and add the item to their cart.

---

# 3. Business Context

Customization (e.g., "Extra Spicy", "No Peanuts") is a huge driver of restaurant revenue and customer satisfaction. The UI here must make selecting options and seeing the total price update in real-time feel effortless.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- `build_menu_screen.md`
- Zustand Cart state initialized.

---

# 6. Scope

## In Scope
- Create the Item Detail view/modal.
- Display large item image, name, and base description.
- Render dynamic lists for `menu_item_options` (radio buttons for single-select, checkboxes for multi-select).
- Implement local state to track current selections and quantity.
- Dynamically calculate and display the total price (Base + Options * Quantity) in the "Add to Cart" button.
- Dispatch the finalized item to the Zustand Cart Store on submit.

## Out of Scope
- Actually syncing the cart to the backend immediately (if doing a pure local-state cart until checkout).

---

# 7. Inputs
- Prop/Route param: The specific `MenuItem` object (including its options).

---

# 8. Required Outputs
- `ItemDetailModal` or page component.
- Form logic (potentially using React Hook Form if options are complex).

---

# 9. Acceptance Criteria
- User can increment/decrement quantity safely.
- Selecting priced options instantly updates the "Add to Cart" total button.
- Required options block the "Add to Cart" button until fulfilled.
- Adding to cart successfully closes the view/modal and updates the global cart state.

---

# 10. Implementation Rules
- Keep calculations precise to avoid float math errors in JS.
- Use Shadcn components for checkboxes/radios for a premium feel.

---

# 11. API / Data Contracts
Writes to the Zustand Cart Store.

---

# 12. Edge Cases
- Adding 99 quantites.
- Making conflicting option selections (handled by radio grouping).

---

# 13. Testing Requirements
- Unit tests for the local price calculation logic.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Public.

---

# 16. Performance Requirements
- Modal animations should run at 60fps without jank.

---

# 17. Deliverable Format
Components and state logic.

---

# 18. Completion Checklist
- [ ] Dynamic price calculation works
- [ ] Required validations work
- [ ] Zustand store updated cleanly

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Form validation should ensure the user cannot proceed without making necessary required choices.

---
End of File
