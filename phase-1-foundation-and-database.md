# Phase 1: Foundation & Local Database Architecture

## 1. Goal
Establish the Flutter project, define the local SQLite architecture with zero-data-loss guarantees across APK updates, and set up the grounded minimalist theme foundation.

---

## 2. Key Deliverables

### A. SQLite Schema (`lib/core/database/`)
Create a persistent relational SQLite database using `sqflite`.
All tables must use integer timestamps (Unix epoch) and explicit primary keys.

#### Table Definitions:
```sql
-- 1. App Configuration & Preferences
CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- 2. Income Entries
CREATE TABLE incomes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT NOT NULL,
    amount REAL NOT NULL,
    cycle_month TEXT NOT NULL, -- Format: 'YYYY-MM'
    created_at INTEGER NOT NULL
);

-- 3. Categories (Envelopes)
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    budget_limit REAL NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('EXPENSE', 'INVESTMENT')),
    icon_name TEXT,
    sort_order INTEGER DEFAULT 0,
    is_archived INTEGER DEFAULT 0
);

-- 4. Transactions
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    description TEXT,
    cycle_month TEXT NOT NULL, -- Format: 'YYYY-MM'
    created_at INTEGER NOT NULL,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

-- 5. Quick Templates (Recurring entries)
CREATE TABLE templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    default_amount REAL NOT NULL,
    default_description TEXT,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- 6. Long-Term Financial Goals & Targets
CREATE TABLE goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    target_amount REAL NOT NULL,
    current_saved REAL DEFAULT 0,
    monthly_budget_allocation REAL DEFAULT 0,
    category_id INTEGER,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET NULL
);
```

### B. Database Migration Manager (`DatabaseHelper`)
- Provide safe schema versioning.
- Ensure foreign keys are enabled: `PRAGMA foreign_keys = ON;`.
- Ensure files are stored in the application's internal database directory (`getDatabasesPath()`) which Android preserves across app updates.

### C. Seed Data
Upon first install, seed default categories:
- **Expenses:** Food (`₹0`), Travel (`₹0`), Rent (`₹0`), Utilities (`₹0`), Miscellaneous (`₹0`).
- **Investments:** Savings Fund (`₹0`), Mutual Funds / Stocks (`₹0`).

### D. Grounded Theme Configuration (`lib/core/theme/`)
- Muted color tokens:
  - `bgPrimary`: `#F7F6F2` (Warm Linen Light) / `#1A1C1E` (Dark Mode)
  - `surface`: `#FFFFFF` / `#232628`
  - `textPrimary`: `#2D312E` / `#E2E3DF`
  - `accentSage` (Investments): `#5E7A68`
  - `accentClay` (Expenses / Overbudget): `#BF5D4B`
  - `accentNeutral`: `#9E9D89`
- Clean, non-distracting typography with legible monospace or semi-bold numerals for financial amounts.

---

## 3. Definition of Done
1. Flutter project compiles for Android.
2. SQLite database initializes and seeds default categories on first launch.
3. Unit test verifies database creation and insertion/query of categories and transactions.

