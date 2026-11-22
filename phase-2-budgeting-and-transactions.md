# Phase 2: Budgeting, Income & Transaction Core Engine

## 1. Goal
Implement the business logic and user interface for managing monthly income (salary/stipend), configuring category envelopes with budgets, and logging transactions with immediate budget balance deduction.

---

## 2. Key Deliverables

### A. Repositories & State Layer
- `IncomeRepository`: Add, update, query total income for current `cycle_month`.
- `CategoryRepository`: Create, update budget limits, classify as `EXPENSE` vs `INVESTMENT`.
- `TransactionRepository`: Insert transaction, fetch transactions for current month or category.
- `BudgetCalculationService`:
  ```dart
  // Core Formulae:
  // Total Income = Sum(Incomes where cycle_month == current)
  // Category Remaining = Category.budget_limit - Sum(Transactions for category in cycle_month)
  // Total Expense Spent = Sum(Transactions where Category.type == EXPENSE)
  // Total Invested = Sum(Transactions where Category.type == INVESTMENT)
  // Unallocated Income = Total Income - Sum(Category.budget_limit)
  ```

### B. Screens & Components

#### 1. Income Allocation Bar / Header
- Displays: Current Month Total Income (Salary/Stipend).
- Tap to edit or add supplementary income.
- Visual badge indicating how much income has been assigned to category budgets vs unassigned.

#### 2. Category List & Budget Assigner (Distinct Expense vs Growth Envelopes)
- **Separated Visual Groups on Screen:**
  - **Expenses (Burn Envelopes):** Food, Rent, Travel, Utilities. Visualized with terracotta accents and remaining balance.
  - **Growth & Assets (Preservation Envelopes):** SIPs, Mutual Funds, Savings Funds. Visualized with sage green accents and completion targets.
- Cards displaying each category:
  - Vector icon + Category Name.
  - Assigned Budget vs Spent/Saved amount.
  - Remaining balance counter (e.g., `₹3,450 left of ₹12,000`).
  - Inline progress bar with clean fill levels.
- Modal to create or edit category names, types, and budget limits.

#### 3. Long-Term Goals & Targets Integration
- Track savings progress against specific financial horizons (Emergency Fund, Travel, Hardware, Big Purchases).
- Each goal defines:
  - `Title`: e.g. "Emergency Corpus", "Japan Trip".
  - `Target Amount`: e.g. ₹1,50,000.
  - `Monthly Budget Allocation`: Planned monthly contribution.
  - `Current Saved`: Amount accumulated till now.
- One-tap `+ Save` button adds funds from surplus cash or investment envelopes directly toward the target.

#### 4. Standard Transaction Form
- Simple screen/dialog:
  - Numerical Amount field (auto-focused).
  - Category selector (chips or dropdown, grouped by Expense vs Investment).
  - Description / Reason field (e.g. "Dinner with friends", "Metro recharge").
  - Date picker (defaults to today).
- Instant validation and submission.

---

## 3. Definition of Done
1. User can enter monthly salary/income.
2. User can set or modify budget limits for any category.
3. Entering a transaction instantly updates the remaining balance in the corresponding category card.
4. Overbudget transactions clearly show negative remaining amount in soft terracotta styling without breaking UI.

