A powerful, high-efficiency Restaurant Admin Dashboard designed for live kitchen operations and business management.

**DESIGN SYSTEM (REQUIRED):**
- **Platform:** Desktop-first Web App (Responsive for Tablet/Mobile use)
- **Theme:** Clean, professional, high-contrast for readability in busy kitchen environments
- **Background:** Soft Gray (#F3F4F6) for page, Solid White (#FFFFFF) for data cards
- **Primary Accent:** Thai Gold (#D9A520) for branding and active navigation
- **Secondary Accent:** Success Green (#10B981) for online status, Alert Red (#EF4444) for urgent orders
- **Typography:** Inter Sans-Serif, tabular figures for data
- **Corners:** 8px to 12px for a more precise, professional feel
- **Elevation:** Subtle shadows to distinguish between different widgets and panels

**Page Structure:**
1. **Sidebar Navigation:**
   - Navigation links: Live Orders (Active), Menu Management, Business Analytics, Inventory, and Settings.
   - Profile section at the bottom with a "Store Open/Closed" toggle switch.

2. **Top Header:**
   - Global search for orders/customers.
   - Quick stats strip: Today's Revenue ($1,420), Active Orders (8), Pending Stock Alerts (3).
   - Date range selector and notification bell.

3. **Active Order Live Feed (Priority):**
   - A grid of active order cards showing: Order ID, Customer Name, Time elapsed (e.g., "12m ago"), and status badges (New, In Kitchen, Ready).
   - Quick action buttons on each card: [Ready for Pickup] or [Print Ticket].

4. **Business Performance Widget:**
   - A simple line chart showing sales trends throughout the day.
   - "Popular Dishes" leaderboard with dish images and quantity sold.

5. **Quick Store Controls (The "Management Hub"):**
   - Single-tap ETA adjustment (15 min, 30 min, 45 min).
   - Kitchen capacity slider.

**Interactions:**
- Order cards should flash or pulse slightly when in "New" status.
- State changes (e.g., clicking "Ready") should have immediate visual feedback without page reloads.

**Design Goal:**
Create a "command center" vibe that feels robust, trustworthy, and extremely fast. It should look as polished as a modern POS system or Stripe's dashboard.

---
💡 **Tip:** For consistent designs across multiple screens, the `DESIGN.md` file is being used to maintain the Phuket Thai visual identity.
