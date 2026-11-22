# Phase 5: Data Safety, Backup & APK Update Pipeline

## 1. Goal
Ensure 100% data preservation across app upgrades, build a reliable JSON/CSV export and import system, and establish an automated in-app update notification flow for personal APK distributions.

---

## 2. Key Deliverables

### A. Data Preservation Guarantee Across APK Updates
- Configure standard **Android Keystore Signing** in `android/app/build.gradle`:
  - Fixed `applicationId` (e.g. `com.personal.financetracker`).
  - Dedicated local release keystore file so all generated APKs share the same certificate.
  - Android will seamlessly install new APK builds over existing ones while keeping the local SQLite database untouched.

### B. Manual Backup & Restore (JSON / CSV)
- **Export Flow:**
  - One-tap button in Settings: *"Export Backup"*.
  - Compiles all tables (`incomes`, `categories`, `transactions`, `templates`, `settings`) into a structured JSON file.
  - Also provides CSV export for transactions (viewable in Excel / Google Sheets).
  - Uses `share_plus` or direct storage write to phone's `Downloads/FinanceTracker/` directory.
- **Import / Restore Flow:**
  - One-tap button: *"Restore Backup"*.
  - File picker to select existing `.json` backup file.
  - Validates schema structure before transactionally replacing or merging data into SQLite.

### C. In-App Update Notification ("Update App Now")
- **Architecture:**
  - Host a simple `version.json` file on a public/private GitHub raw URL (or GitHub Releases):
    ```json
    {
      "version_code": 2,
      "version_name": "1.1.0",
      "apk_url": "https://github.com/<user>/<repo>/releases/download/v1.1.0/app-release.apk",
      "release_notes": "Added investment breakdown chart and faster quick-add."
    }
    ```
- **In-App Prompt:**
  - App checks this endpoint on launch (or via a "Check for Updates" button in Settings).
  - If remote `version_code` > current `package_info` version:
    - Displays a non-intrusive banner or dialog: **"Update Available (v1.1.0). Tap to download and update."**
    - Directly downloads the APK and prompts Android's native package installer.

---

## 3. Definition of Done
1. Exporting data produces a valid, readable JSON and CSV backup on the phone.
2. Restoring a JSON file completely repopulates all categories, transactions, and settings.
3. An updated APK can be installed over an existing installation without any data loss.
4. Version check service successfully notifies the user when an update is available.

