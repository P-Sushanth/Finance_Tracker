/// Table and column contracts for the SQLite database.
class DatabaseTables {
  DatabaseTables._();

  // Table Names
  static const String appSettings = 'app_settings';
  static const String incomes = 'incomes';
  static const String categories = 'categories';
  static const String transactions = 'transactions';
  static const String templates = 'templates';
  static const String goals = 'goals';

  // Create Table Statements
  static const String createAppSettingsTable = '''
    CREATE TABLE $appSettings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''';

  static const String createIncomesTable = '''
    CREATE TABLE $incomes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      cycle_month TEXT NOT NULL,
      created_at INTEGER NOT NULL
    );
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE $categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      budget_limit REAL NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('EXPENSE', 'INVESTMENT')),
      icon_name TEXT,
      sort_order INTEGER DEFAULT 0,
      is_archived INTEGER DEFAULT 0
    );
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      description TEXT,
      cycle_month TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY(category_id) REFERENCES $categories(id) ON DELETE RESTRICT
    );
  ''';

  static const String createTemplatesTable = '''
    CREATE TABLE $templates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      default_amount REAL NOT NULL,
      default_description TEXT,
      sort_order INTEGER DEFAULT 0,
      FOREIGN KEY(category_id) REFERENCES $categories(id) ON DELETE CASCADE
    );
  ''';

  static const String createGoalsTable = '''
    CREATE TABLE $goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      target_amount REAL NOT NULL,
      current_saved REAL DEFAULT 0,
      monthly_budget_allocation REAL DEFAULT 0,
      category_id INTEGER,
      created_at INTEGER NOT NULL,
      FOREIGN KEY(category_id) REFERENCES $categories(id) ON DELETE SET NULL
    );
  ''';

  // Performance Indexes
  static const String createTransactionsMonthIndex = '''
    CREATE INDEX idx_transactions_cycle_month ON $transactions (cycle_month);
  ''';

  static const String createIncomesMonthIndex = '''
    CREATE INDEX idx_incomes_cycle_month ON $incomes (cycle_month);
  ''';
}

