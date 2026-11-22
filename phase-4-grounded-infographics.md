# Phase 4: Grounded Infographics & Visual Dashboard

## 1. Goal
Provide a dedicated, in-depth **Infographics & Analytics screen** that cleanly separates **Outflow (True Expenses)** from **Asset Building (Savings & Investments)**. Provide daily burn rate velocity, spending pace markers, and category contribution breakdown using minimalist, non-distracting vector charts.

---

## 2. Key Deliverables

### A. Visual Philosophy & Icon System
- Minimalist Scandinavian / Japanese aesthetic.
- Zero emojis: Clean monochrome vector SVG line icons.
- Grounded color palette:
  - **Sage Green (`#4D7266`)**: Assets, Investments, Healthy Budgets.
  - **Muted Terracotta (`#BA4E3B`)**: True Expenses, Approaching/Exceeded Budgets.
  - **Deep Charcoal (`#2A363B`)**: Neutral metrics, Total Inflow, Navigation.

### B. Dedicated Analytics Screen Sections

#### 1. Swipable 3-Page Donut Carousel
- A single, compact swipable card with 3 pagination indicator dots (`● ○ ○`):
  - **Page 1: Net Flow Split**
    - Muted Terracotta: Burn / Outflow (True Expenses).
    - Sage Green: Asset Growth (Investments).
    - Neutral Slate: Unspent Surplus (Free Cash).
    - Interactive tap: Clicking any segment updates the center with its percentage.
  - **Page 2: Burn Distribution**
    - Proportional slices showing where burned money went across categories (Rent, Food, Utilities, Travel).
    - Interactive tap: Clicking any slice updates the center with its percentage of total burn.
  - **Page 3: Growth Allocation (Investments)**
    - Proportional slices showing where invested money went across investment/savings envelopes (e.g., Nifty 50 Index SIP, Emergency Fund).
    - Interactive tap: Clicking any slice updates the center with its percentage of total growth.

#### 2. Lifetime (Historical Cumulative Infographics)
- Retains memory across all past months to visualize compounding personal progress:
  - **Invested:** Cumulative total invested in wealth over app lifetime.
  - **Saved:** Cumulative unspent surplus preserved in bank/emergency funds.
  - **Burned:** Cumulative true expenses consumed over app lifetime.

#### 4. Filterable Transaction Feed
- List view beneath the visual dashboard:
  - Filter by: `All`, `Expenses Only`, `Investments Only`, or specific Category.
  - Displays: Date, Category badge, Description, and Amount.
  - Swipe-to-delete or tap-to-edit with instant balance recalculation.

---

## 3. Definition of Done
1. Dashboard clearly visualizes Expenses vs. Investments in separate visual groups.
2. Infographics render cleanly without lagging or layout overflow on various mobile screen sizes.
3. Visual indicators accurately reflect real-time spending pace against category limits.

