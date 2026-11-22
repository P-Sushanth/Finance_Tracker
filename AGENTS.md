# AGENTS.md - Project Context & Developer Reference

> **Important for AI Agents & Developers:** This file provides complete, 0-context onboarding for this repository. Read this file first before inspecting or modifying code.

---

## 1. Project Overview & Vision
This is a **personal, offline-first personal finance tracking mobile app** built for Android using Flutter. It is designed specifically for **daily friction-free personal use** (not for public release, hackathons, or resumes).

### Core Goals:
1. **Speed & Simplicity:** Transaction logging must take < 5 seconds with minimal clicks ("Quick-Add").
2. **Budget Envelope Management:** Deducts expenses in real time against user-defined monthly category budgets.
3. **Clear Infographic Distinction:** Visual separation between **Outflow (True Expenses)** (money spent) and **Asset Growth (Savings / Investments)** (money preserved).
4. **Data Sovereignty & Persistence:** 100% offline local storage (SQLite). Data must survive APK version updates seamlessly, and allow full manual export/import (JSON/CSV).
5. **Aesthetic:** Grounded, minimalist, muted earthy/neutral color palette (Nordic / Japanese minimalist: charcoal, warm off-white, muted sage, soft terracotta). No bright neon or cluttered financial UI.

---

## 2. Core Functional Requirements
- **Income Management:** Track monthly salary, stipend, or one-off inflows.
- **Categories & Budgets:** Custom categories (e.g., Food, Travel, Rent, Savings, Investments, Misc). Each category has:
  - An assigned monthly budget.
  - A strict classification type: `EXPENSE` or `INVESTMENT`.
- **Transaction Logging:** Deducts immediately from the target category's budget. Includes amount, category, date, and optional description/reason.
- **Recurring Templates:** Quick-apply presets for regular monthly transactions (Rent, SIPs, WiFi, Stipend).
- **Monthly Reset & Rollover:** Support for custom month cycle dates (e.g., 1st or 25th) with clean monthly reset and historical archive.
- **Visual Infographics:** Minimalist charts/gauges distinguishing Burn (Expenses) vs. Growth (Investments) and category health.
- **Data Backup & Restore:** Export all tables to JSON/CSV directly to device storage; restore from JSON.
- **Update Resilience:** Stable Android Keystore signing and SQLite migrations so new APK installs never wipe existing app data.

---

## 3. Technology Stack & Key Libraries
- **Framework:** Flutter (Targeting Android SDK / APK).
- **State Management:** Riverpod or lightweight ChangeNotifier / BLoC (keep it lightweight and testable).
- **Local Persistence:** `sqflite` + `path` (relational database with foreign keys, indexes, and versioned migrations).
- **Charts / Infographics:** `fl_chart` (custom-styled with muted palette) or custom canvas painters.
- **File & Storage Handling:** `file_picker`, `path_provider`, `share_plus` for backup exports and imports.
- **Update Checks:** `http` / GitHub Releases API or local version checking.

---

## 4. Directory Structure (Architecture Standard)

```
lib/
├── core/
│   ├── constants/        # Muted color schemes, typography, dimensions
│   ├── database/         # SQLite openHelper, migrations, table contracts
│   ├── utils/            # Date formatting, currency helpers, export/import helpers
│   └── theme/            # Minimalist light/dark theme data
├── features/
│   ├── income/           # Inflow tracking models, repos, UI
│   ├── categories/       # Category definition, envelope budget logic
│   ├── transactions/     # Add transaction, Quick-Add sheet, templates
│   ├── infographics/     # Expense vs Investment analytics, budget gauges
│   └── backup/           # JSON/CSV exporter, importer, update checker
├── shared/
│   ├── models/           # Shared domain entities
│   └── widgets/          # Custom keypad, grounded progress bars, pill chips
└── main.dart             # Entry point, dependency initialization
```

---

## 5. Implementation Phases
Detailed specifications for each phase are documented in their respective phase files:

| Phase | Spec File | Focus Area |
| :--- | :--- | :--- |
| **Phase 1** | [`phase-1-foundation-and-database.md`](file:///c:/Users/popur/Documents/Projects/Finance_Tracker/phase-1-foundation-and-database.md) | Flutter setup, SQLite schema, persistence contracts, styling foundation. |
| **Phase 2** | [`phase-2-budgeting-and-transactions.md`](file:///c:/Users/popur/Documents/Projects/Finance_Tracker/phase-2-budgeting-and-transactions.md) | Income tracking, category budgets, transaction deduction engine. |
| **Phase 3** | [`phase-3-quick-add-templates-reset.md`](file:///c:/Users/popur/Documents/Projects/Finance_Tracker/phase-3-quick-add-templates-reset.md) | Quick-Add bottom sheet, recurring templates, monthly reset cycle. |
| **Phase 4** | [`phase-4-grounded-infographics.md`](file:///c:/Users/popur/Documents/Projects/Finance_Tracker/phase-4-grounded-infographics.md) | Visual analytics, Outflow vs. Growth distinction, budget progress bars. |
| **Phase 5** | [`phase-5-backup-update-pipeline.md`](file:///c:/Users/popur/Documents/Projects/Finance_Tracker/phase-5-backup-update-pipeline.md) | JSON/CSV backup/restore, Keystore signing, In-app APK update notification. |

---

## 6. Coding Standards & Guidelines for AI Agents
1. **Never Break Database Compatibility:** Never drop tables on database version upgrades. Always write additive migrations (`ALTER TABLE ... ADD COLUMN ...`).
2. **Keep Business Logic Testable:** Separate database queries (repositories) from UI widgets.
3. **No Over-Engineering:** Keep models lean. Avoid bloated boilerplate.
4. **Always Preserve Offline First:** Never introduce required network calls for standard app functionality.
5. **Colors:** Stick strictly to the defined grounded theme:
   - Background: Warm off-white / Linen (`#F9F8F6`) or Slate Dark (`#1E2022`).
   - Primary: Charcoal / Deep Slate (`#2B303A`).
   - Investments / Growth: Muted Olive / Sage Green (`#6B8E6F` / `#8FA89B`).
   - Expenses / Caution: Terracotta / Muted Clay (`#C86D51` / `#D48C70`).

