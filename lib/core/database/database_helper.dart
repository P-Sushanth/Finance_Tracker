import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../shared/models/app_setting_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/income_model.dart';
import '../../shared/models/template_model.dart';
import '../../shared/models/transaction_model.dart';
import 'database_tables.dart';

class DatabaseHelper {
  static const String _databaseName = 'finance_tracker.db';
  static const int _databaseVersion = 1;

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseFactory? _customFactory;
  String? _customPath;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Factory constructor for testing with in-memory or custom SQLite instances
  factory DatabaseHelper.withFactory({
    required DatabaseFactory factory,
    String? customPath,
  }) {
    _instance = DatabaseHelper._internal()
      .._customFactory = factory
      .._customPath = customPath ?? inMemoryDatabasePath;
    _database = null;
    return _instance!;
  }

  static void resetInstance({DatabaseFactory? factory, String? customPath}) {
    _database = null;
    _instance = DatabaseHelper._internal()
      .._customFactory = factory
      .._customPath = customPath ?? inMemoryDatabasePath;
  }

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = _customPath ??
        p.join(await getDatabasesPath(), _databaseName);

    final factory = _customFactory ?? databaseFactory;

    return await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enforce foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createAppSettingsTable);
    await db.execute(DatabaseTables.createIncomesTable);
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createTransactionsTable);
    await db.execute(DatabaseTables.createTemplatesTable);
    await db.execute(DatabaseTables.createGoalsTable);

    await db.execute(DatabaseTables.createTransactionsMonthIndex);
    await db.execute(DatabaseTables.createIncomesMonthIndex);

    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Additive migrations only (never DROP tables!)
    // e.g. if (oldVersion < 2) { ... }
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Seed Essential Settings (Currency symbol & Cycle start day)
    await db.insert(
      DatabaseTables.appSettings,
      const AppSettingModel(key: 'currency_symbol', value: '₹').toMap(),
    );
    await db.insert(
      DatabaseTables.appSettings,
      const AppSettingModel(key: 'cycle_start_day', value: '1').toMap(),
    );
    // Presets removed: User begins with a clean slate to add custom envelopes from scratch.
  }

  /// Clears all categories, templates, transactions, incomes, and goals
  /// leaving the app in a 100% clean state for starting from scratch.
  Future<void> resetToScratch() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.transactions);
      await txn.delete(DatabaseTables.incomes);
      await txn.delete(DatabaseTables.templates);
      await txn.delete(DatabaseTables.goals);
      await txn.delete(DatabaseTables.categories);
    });
  }

  // ================= CATEGORY QUERIES =================

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert(DatabaseTables.categories, category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.categories,
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(CategoryType type, {bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.categories,
      where: includeArchived
          ? 'type = ?'
          : 'type = ? AND is_archived = 0',
      whereArgs: [type.toDbValue()],
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      DatabaseTables.categories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= INCOME QUERIES =================

  Future<int> insertIncome(IncomeModel income) async {
    final db = await database;
    return await db.insert(DatabaseTables.incomes, income.toMap());
  }

  Future<List<IncomeModel>> getIncomesForMonth(String cycleMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.incomes,
      where: 'cycle_month = ?',
      whereArgs: [cycleMonth],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => IncomeModel.fromMap(map)).toList();
  }

  Future<double> getTotalIncomeForMonth(String cycleMonth) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseTables.incomes} WHERE cycle_month = ?',
      [cycleMonth],
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  // ================= TRANSACTION QUERIES =================

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(DatabaseTables.transactions, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactionsForMonth(String cycleMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.transactions,
      where: 'cycle_month = ?',
      whereArgs: [cycleMonth],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<double> getCategorySpentForMonth(int categoryId, String cycleMonth) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseTables.transactions} WHERE category_id = ? AND cycle_month = ?',
      [categoryId, cycleMonth],
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.transactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getRecordedCycleMonths() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT DISTINCT cycle_month FROM ${DatabaseTables.transactions}
      UNION
      SELECT DISTINCT cycle_month FROM ${DatabaseTables.incomes}
      ORDER BY cycle_month DESC
    ''');
    return results.map((r) => r['cycle_month'] as String).toList();
  }

  // ================= LIFETIME ANALYTICS QUERIES =================

  Future<double> getLifetimeInflow() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM ${DatabaseTables.incomes}');
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<double> getLifetimeBurned() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(t.amount) as total
      FROM ${DatabaseTables.transactions} t
      JOIN ${DatabaseTables.categories} c ON t.category_id = c.id
      WHERE c.type = ?
    ''', [CategoryType.expense.toDbValue()]);
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<double> getLifetimeInvested() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(t.amount) as total
      FROM ${DatabaseTables.transactions} t
      JOIN ${DatabaseTables.categories} c ON t.category_id = c.id
      WHERE c.type = ?
    ''', [CategoryType.investment.toDbValue()]);
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<int> getLifetimeMonthsCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT cycle_month) as count FROM (
        SELECT cycle_month FROM ${DatabaseTables.transactions}
        UNION
        SELECT cycle_month FROM ${DatabaseTables.incomes}
      )
    ''');
    final count = result.first['count'];
    return count != null ? (count as num).toInt() : 0;
  }

  // ================= TEMPLATE QUERIES =================

  Future<int> insertTemplate(TemplateModel template) async {
    final db = await database;
    return await db.insert(DatabaseTables.templates, template.toMap());
  }

  Future<List<TemplateModel>> getAllTemplates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.templates,
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((map) => TemplateModel.fromMap(map)).toList();
  }

  Future<int> updateTemplate(TemplateModel template) async {
    final db = await database;
    return await db.update(
      DatabaseTables.templates,
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.templates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= GOAL QUERIES =================

  Future<int> insertGoal(GoalModel goal) async {
    final db = await database;
    return await db.insert(DatabaseTables.goals, goal.toMap());
  }

  Future<List<GoalModel>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.goals,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }

  Future<int> updateGoal(GoalModel goal) async {
    final db = await database;
    return await db.update(
      DatabaseTables.goals,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseTables.goals,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= APP SETTINGS QUERIES =================

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.appSettings,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      DatabaseTables.appSettings,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ================= BACKUP & RESTORE QUERIES =================

  /// Exports all database tables to a structured map.
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    final categories = await db.query(DatabaseTables.categories);
    final incomes = await db.query(DatabaseTables.incomes);
    final transactions = await db.query(DatabaseTables.transactions);
    final templates = await db.query(DatabaseTables.templates);
    final goals = await db.query(DatabaseTables.goals);
    final appSettings = await db.query(DatabaseTables.appSettings);

    return {
      'version': _databaseVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'FinanceTracker',
      'data': {
        DatabaseTables.categories: categories,
        DatabaseTables.incomes: incomes,
        DatabaseTables.transactions: transactions,
        DatabaseTables.templates: templates,
        DatabaseTables.goals: goals,
        DatabaseTables.appSettings: appSettings,
      },
    };
  }

  /// Exports all transactions with category info as a CSV string.
  Future<String> exportTransactionsCsv() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        t.id,
        t.created_at,
        c.name as category_name,
        c.type as category_type,
        t.amount,
        t.description,
        t.cycle_month
      FROM ${DatabaseTables.transactions} t
      LEFT JOIN ${DatabaseTables.categories} c ON t.category_id = c.id
      ORDER BY t.created_at DESC
    ''');

    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Time,Category,Type,Amount,Description,CycleMonth');

    for (final row in results) {
      final id = row['id'];
      final createdAt = row['created_at'] as int;
      final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
      final dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final catName = (row['category_name'] ?? 'Uncategorized').toString().replaceAll('"', '""');
      final type = row['category_type'] ?? 'EXPENSE';
      final amount = row['amount'];
      final rawDesc = (row['description'] ?? '').toString().replaceAll('"', '""');
      final desc = '"$rawDesc"';
      final cycle = row['cycle_month'];

      buffer.writeln('$id,$dateStr,$timeStr,"$catName",$type,$amount,$desc,$cycle');
    }

    return buffer.toString();
  }

  /// Transactionally restores all database tables from a backup map.
  Future<bool> restoreAllData(Map<String, dynamic> backup) async {
    final rawData = backup['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload: missing "data" key.');
    }

    final db = await database;
    await db.transaction((txn) async {
      // 1. Clear existing data in reverse dependency order
      await txn.delete(DatabaseTables.transactions);
      await txn.delete(DatabaseTables.templates);
      await txn.delete(DatabaseTables.goals);
      await txn.delete(DatabaseTables.incomes);
      await txn.delete(DatabaseTables.categories);
      await txn.delete(DatabaseTables.appSettings);

      // 2. Insert Categories
      final categories = (rawData[DatabaseTables.categories] as List?) ?? [];
      for (final item in categories) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.categories, item);
        }
      }

      // 3. Insert Incomes
      final incomes = (rawData[DatabaseTables.incomes] as List?) ?? [];
      for (final item in incomes) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.incomes, item);
        }
      }

      // 4. Insert Transactions
      final transactions = (rawData[DatabaseTables.transactions] as List?) ?? [];
      for (final item in transactions) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.transactions, item);
        }
      }

      // 5. Insert Templates
      final templates = (rawData[DatabaseTables.templates] as List?) ?? [];
      for (final item in templates) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.templates, item);
        }
      }

      // 6. Insert Goals
      final goals = (rawData[DatabaseTables.goals] as List?) ?? [];
      for (final item in goals) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.goals, item);
        }
      }

      // 7. Insert App Settings
      final appSettings = (rawData[DatabaseTables.appSettings] as List?) ?? [];
      for (final item in appSettings) {
        if (item is Map<String, dynamic>) {
          await txn.insert(DatabaseTables.appSettings, item);
        }
      }
    });

    return true;
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}

