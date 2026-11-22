import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/goal_model.dart';
import 'package:finance_tracker/shared/models/income_model.dart';
import 'package:finance_tracker/shared/models/template_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize ffi for testing SQLite on host machine
  sqfliteFfiInit();

  group('DatabaseHelper & Schema Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Use in-memory SQLite database for test isolation
      dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: inMemoryDatabasePath,
      );
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Initializes schema and seeds default categories and settings', () async {
      final categories = await dbHelper.getAllCategories();
      expect(categories.length, equals(7));

      final expenses = await dbHelper.getCategoriesByType(CategoryType.expense);
      expect(expenses.length, equals(5));
      expect(expenses.map((c) => c.name), containsAll([
        'Food & Dining',
        'Travel & Commute',
        'House Rent',
        'Utilities',
        'Miscellaneous',
      ]));

      final investments = await dbHelper.getCategoriesByType(CategoryType.investment);
      expect(investments.length, equals(2));
      expect(investments.map((c) => c.name), containsAll([
        'SIP & Mutual Funds',
        'Emergency Fund',
      ]));

      final currency = await dbHelper.getSetting('currency_symbol');
      expect(currency, equals('₹'));

      final cycleStartDay = await dbHelper.getSetting('cycle_start_day');
      expect(cycleStartDay, equals('1'));
    });

    test('Records income entries and calculates total income for cycle month', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await dbHelper.insertIncome(IncomeModel(
        source: 'Monthly Salary',
        amount: 85000.0,
        cycleMonth: '2026-11',
        createdAt: now,
      ));

      await dbHelper.insertIncome(IncomeModel(
        source: 'Freelance Bonus',
        amount: 15000.0,
        cycleMonth: '2026-11',
        createdAt: now + 1000,
      ));

      // Another month to verify filtering
      await dbHelper.insertIncome(IncomeModel(
        source: 'Previous Salary',
        amount: 80000.0,
        cycleMonth: '2026-10',
        createdAt: now - 100000,
      ));

      final incomesNov = await dbHelper.getIncomesForMonth('2026-11');
      expect(incomesNov.length, equals(2));

      final totalNov = await dbHelper.getTotalIncomeForMonth('2026-11');
      expect(totalNov, equals(100000.0));

      final totalOct = await dbHelper.getTotalIncomeForMonth('2026-10');
      expect(totalOct, equals(80000.0));
    });

    test('Inserts transactions and calculates category spent per cycle month', () async {
      final categories = await dbHelper.getAllCategories();
      final foodCat = categories.firstWhere((c) => c.name == 'Food & Dining');
      final travelCat = categories.firstWhere((c) => c.name == 'Travel & Commute');

      final now = DateTime.now().millisecondsSinceEpoch;

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCat.id!,
        amount: 450.0,
        description: 'Lunch',
        cycleMonth: '2026-11',
        createdAt: now,
      ));

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCat.id!,
        amount: 850.0,
        description: 'Groceries',
        cycleMonth: '2026-11',
        createdAt: now + 500,
      ));

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: travelCat.id!,
        amount: 200.0,
        description: 'Metro',
        cycleMonth: '2026-11',
        createdAt: now + 1000,
      ));

      final foodSpent = await dbHelper.getCategorySpentForMonth(foodCat.id!, '2026-11');
      expect(foodSpent, equals(1300.0));

      final travelSpent = await dbHelper.getCategorySpentForMonth(travelCat.id!, '2026-11');
      expect(travelSpent, equals(200.0));

      final allNovTxs = await dbHelper.getTransactionsForMonth('2026-11');
      expect(allNovTxs.length, equals(3));
    });

    test('Enforces foreign key constraint on deleting category with active transactions', () async {
      final categories = await dbHelper.getAllCategories();
      final foodCat = categories.firstWhere((c) => c.name == 'Food & Dining');

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCat.id!,
        amount: 300.0,
        description: 'Snacks',
        cycleMonth: '2026-11',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

      // Attempting to delete category should fail due to ON DELETE RESTRICT
      expect(
        () async => await dbHelper.deleteCategory(foodCat.id!),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Manages recurring templates and goals CRUD operations', () async {
      final categories = await dbHelper.getAllCategories();
      final rentCat = categories.firstWhere((c) => c.name == 'House Rent');

      // 1. Template
      final templateId = await dbHelper.insertTemplate(TemplateModel(
        title: 'Monthly Rent',
        categoryId: rentCat.id!,
        defaultAmount: 22000.0,
        defaultDescription: 'Apartment Rent',
      ));
      expect(templateId, greaterThan(0));

      final templates = await dbHelper.getAllTemplates();
      expect(templates.length, equals(4)); // 3 seeded + 1 inserted
      expect(templates.any((t) => t.title == 'Monthly Rent'), isTrue);

      // 2. Goal
      final goalId = await dbHelper.insertGoal(GoalModel(
        title: 'Emergency Corpus',
        targetAmount: 150000.0,
        currentSaved: 20000.0,
        monthlyBudgetAllocation: 10000.0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      expect(goalId, greaterThan(0));

      final goals = await dbHelper.getAllGoals();
      expect(goals.length, equals(1));
      expect(goals.first.title, equals('Emergency Corpus'));
      expect(goals.first.targetAmount, equals(150000.0));
      expect(goals.first.currentSaved, equals(20000.0));
    });
  });
}

