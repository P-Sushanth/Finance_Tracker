# UI/UX Wireframe & Design System Reference (V2)

This document describes the updated screen layout, vector icon system, dedicated analytics screen, template management, and cash inflow logging.

An interactive mobile prototype is available at [wireframe.html](file:///C:/Users/popur/.gemini/antigravity/brain/b3fd354b-406a-4bd0-9743-42f442708d87/wireframe.html).

---

## 1. Design & Icon System
- **No Emojis:** Replaced all informal emojis with clean, thin-stroke monochrome SVG vector icons (Material/Lucide style).
- **Aesthetic:** Minimalist grounded theme (Warm Linen `#F5F4F0`, Sage Green `#4D7266` for Growth, Muted Terracotta `#BA4E3B` for Outflow, and Deep Charcoal `#2A363B`).

---

## 2. Updated Navigation & Screen Structure

### 5-Icon Minimalist Floating Bottom Bar:
- Clean minimalist dock with **no text labels**:
  - `Home` (House icon)
  - `Analytics` (Chart icon)
  - `+` (Elevated Sage green center Quick-Add button)
  - `Goals` (Target bullseye icon)
  - `Presets` (List/Templates icon)

---

## 3. Screen Layout Breakdown

### Screen 1: Home (Envelopes & Balance)
- **Top Header:** Clean cycle month selector (`November 2026` + `Day 21 / 30`).
- **Interactive Balance Summary Bar:**
  - Displays Total Inflow and Unspent balance.
  - **Touch/Tap Tooltip:** Tapping or hovering over each segment displays an interactive floating pill tooltip (`Outflow: ₹40,800 • 48%`, `Invested: ₹27,200 • 32%`, `Unspent: ₹17,000 • 20%`).
- **Swipeable / Switchable 2-Page Envelope Tabs:**
  - Clean text tabs with no color dots (`Expenses` vs `Growth`):
    - **Page 1 (Expenses):** Food, Travel, Rent (Terracotta accent bars with remaining budget).
    - **Page 2 (Growth):** Nifty 50 Index Fund, Emergency Fund (Sage green accent bars with target progress).

### Screen 2: Dedicated Infographics & Analytics Page
- **Swipable 3-Page Donut Carousel:**
  - A clean swipable container with 3 pagination indicator dots (`● ○ ○`) and navigation arrows:
    - **Page 1: Net Flow Split (Burned, Invested, Saved)**
      - Terracotta: Burned (48%).
      - Sage: Invested (32%).
      - Neutral: Saved (20%).
      - Interactive Tap: Clicking any segment updates the center with its percentage and amount.
    - **Page 2: Burn Distribution (Where Burned Money Went)**
      - Rent: 54%
      - Food: 21%
      - Utilities: 20%
      - Travel: 5%
    - **Page 3: Growth Allocation (Where Invested Money Went)**
      - Nifty 50 SIP: 55% of Growth (₹15,000)
      - Emergency Fund: 45% of Growth (₹12,200)
- **Lifetime:**
  - Cumulative metrics across all historical cycles:
    - **Invested:** Cumulative total invested in wealth (₹3.80 L).
    - **Saved:** Cumulative unspent surplus preserved (₹1.95 L).
    - **Burned:** Cumulative expenses consumed (₹5.42 L).

### Screen 3: Dedicated Goals & Targets Screen
- **Overall Corpus Progress Bar:** Displays total accumulated across all goals vs overall target (e.g. ₹1,85,000 of ₹3,50,000 • 53% achieved).
- **Target Cards:**
  - Goal Title & Category icon (e.g. *Emergency 6-Month Corpus*, *Japan Trip Fund*, *Workstation Upgrade*).
  - Target amount, monthly contribution allocation, and amount saved till now.
  - Clean progress bar + `+ Save` button to deposit savings directly into the target.

### Screen 4: Unified Quick-Add (+) Sheet (Inflow & Outflow)
- **Unified Inflow / Outflow Toggle at the Top:**
  - **Outflow Mode (Default):** Shows category chips (Food, Travel, Rent) and deducts from envelope budgets.
  - **Inflow Mode:** No category chips needed. Numeric keypad to enter amount and a simple source note.
- **Unified Data Connection:** Entering a transaction immediately deducts from the envelope, updates the Home summary bar, recalculates the Analytics donut charts, and logs to the Recent Activity list.

### Screen 5: Recurring Presets (Templates Management)
- **Actions:**
  - `+ New Preset`: Create a new custom template.
  - `Edit`: Change title, default amount, category, or note.
  - `Delete`: Remove template.
  - `Apply`: 1-tap execution into current month.
