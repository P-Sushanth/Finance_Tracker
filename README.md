# Personal Finance Tracker

A grounded, offline-first personal finance tracking mobile app built for Android using Flutter. Designed specifically for daily friction-free personal use with zero financial clutter.

---

## 🌿 Core Features

1. **< 5-Second Frictionless Quick-Add:**
   - Dedicated 3-column numeric keypad for one-handed thumb logging.
   - Outflow vs. Inflow toggle (Inflows require zero category categorization; Outflows deduct instantly against target envelope).
2. **Real-Time Budget Envelope Deductions:**
   - Monthly category limits (Food, Travel, Rent, Utilities, Misc, SIPs, Emergency Funds).
   - Instant visual deduction and remaining balance calculation.
3. **Outflow (Burn) vs. Growth (Asset Building) Separation:**
   - Visual distinction between money burned (expenses) and wealth accumulated (investments / SIPs).
   - 2-page segmented tabs for Envelopes on the Home screen.
4. **Swipable 3-Page Donut Carousel:**
   - **Page 1: Net Flow Split** (Terracotta for Outflow, Sage for Investments, Slate for Unspent).
   - **Page 2: Burn Distribution** (Where burned money went across expense envelopes).
   - **Page 3: Growth Allocation** (Asset-building envelopes distribution).
   - Interactive center hub updates with amount and percentage on segment tap.
5. **Recurring Transaction Presets:**
   - 1-Tap apply for periodic expenses and investments (Rent, SIPs, WiFi Bill).
   - Full CRUD support (Add, Edit, Delete).
6. **Configurable Month Cycle & Reset Engine:**
   - Custom cycle start date (e.g. 1st or salary day like 25th).
   - Historical archive selector to review past months.
7. **100% Data Sovereignty & Offline Persistence:**
   - Local SQLite relational database with foreign keys and performance indexes.
   - Full JSON database export/import and spreadsheet-compatible CSV export.
   - Update resilience via fixed Android Keystore signing.

---

## 🎨 Aesthetic & Design Philosophy

- **Nordic / Japanese Minimalist:**
  - Linen Off-White (`#F9F8F6`) and Deep Charcoal Slate (`#2A363B`).
  - Muted Sage Green (`#4D7266` / `#8FA89B`) for Assets & Growth.
  - Muted Terracotta (`#BA4E3B` / `#D48C70`) for Outflows & Caution.
- **Vector Icons Only:** Zero emojis; clean Material line vector icons.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── core/
│   ├── constants/        # Muted color tokens, dimensions
│   ├── database/         # SQLite openHelper, migrations, contracts
│   ├── utils/            # Currency formatter, date helpers
│   └── theme/            # Grounded light/dark theme data
├── features/
│   ├── analytics/        # Custom donut charts, lifetime stats
│   ├── backup/           # JSON/CSV exporter, importer, update checker
│   ├── budget/           # Budget controller & repository
│   ├── categories/       # Envelope budget dialogs
│   ├── goals/            # Long-term goals & target progress
│   ├── home/             # Segmented envelopes, balance card
│   ├── income/           # Inflow logging modal
│   ├── quick_add/        # Custom keypad quick-add bottom sheet
│   ├── settings/         # Data sovereignty, backup & update UI
│   ├── shell/            # 5-icon floating bottom dock
│   └── templates/        # 1-tap recurring presets screen
├── shared/
│   ├── models/           # Domain entities (Category, Transaction, Income, Goal, Template)
│   └── widgets/          # Interactive balance card, envelope cards
└── main.dart             # App entrypoint
```

---

## 🧪 Testing

The codebase includes complete automated test coverage:
- `test/database_test.dart`: SQLite tables, foreign keys, and seed integrity.
- `test/budget_controller_test.dart`: Immediate envelope deductions and budget limits.
- `test/phase3_test.dart`: Quick-Add numeric keypad, template apply, and cycle switcher.
- `test/analytics_test.dart`: Donut slice math, Lifetime metrics, and transaction feed filters.
- `test/phase5_backup_test.dart`: Full JSON/CSV backup, restore, and update service.
- `test/widget_test.dart`: Main application shell.

Run all tests:
```bash
flutter test
```

---

## 🚀 Building & Running

### Android APK:
```bash
flutter build apk --release
```

### Local Development:
```bash
flutter run
```
