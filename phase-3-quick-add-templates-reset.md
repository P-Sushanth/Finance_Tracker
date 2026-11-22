# Phase 3: Fast Entry, Templates & Monthly Reset Logic

## 1. Goal
Optimize the app for daily personal speed. Introduce a < 5-second "Quick-Add" sheet, reusable recurring transaction templates (Rent, SIPs, WiFi), and a flexible monthly reset/rollover mechanism.

---

## 2. Key Deliverables

### A. Frictionless Unified Quick-Add Sheet (Inflow & Outflow Toggle)
- Accessible from the central elevated `+` button in the minimalist bottom dock.
- **Unified Inflow / Outflow Segmented Toggle:**
  - **Outflow (Default):** Deducts money against selected category envelope (Food, Travel, Rent).
  - **Inflow:** Adds salary, stipend, or one-off inflow to the monthly pool (Salary, Freelance, Gift).
- **Design:**
  - Integrated custom numpad for one-handed thumb entry.
  - Category pill chips adapt dynamically depending on whether Inflow or Outflow is toggled.
  - Reason/Description input with automatic suggestions based on past entries.
  - Single tap "Record Outflow" or "Record Inflow" with haptic feedback. Target: < 5 seconds per entry.

### B. Recurring Transaction Templates (Full CRUD)
- Template management for fixed periodic transactions:
  - Examples: "Monthly House Rent", "Index Fund SIP", "WiFi Bill", "Monthly Stipend".
- **Template Actions:**
  - **Create:** Add new template with title, category, default amount, and optional note.
  - **Edit:** Update amount, title, or target category.
  - **Delete:** Remove templates no longer needed.
  - **1-Tap Apply:** Tapping "Apply" confirms amount and logs it immediately for the current month cycle.

### C. Monthly Cycle & Reset Engine
- Configurable **Cycle Start Day** in Settings:
  - Default: `1st of the month`.
  - Configurable to salary date (e.g. `25th` to `24th` of next month).
- **Reset Logic:**
  - The app automatically recognizes when a new cycle begins.
  - Budget allocations roll over or re-apply for the new cycle.
  - Past cycle transactions are archived under their corresponding `cycle_month` (e.g., `2026-10`, `2026-11`).
  - Dropdown / swipe selector on dashboard to review previous months' records at any time.

---

## 3. Definition of Done
1. Quick-Add sheet allows logging an expense in under 5 seconds.
2. User can create and execute recurring templates with 1-2 taps.
3. Switching cycle month retains past transaction logs and resets current month balances cleanly.

