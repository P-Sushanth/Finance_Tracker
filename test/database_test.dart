import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/goal_model.dart';
import 'package:finance_tracker/shared/models/income_model.dart';
import 'package:finance_tracker/shared/models/template_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();

  group('DatabaseHelper & Schema Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      final dbName = 'test_db_${DateTime.now().microsecondsSinceEpoch}.db';
      dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Initializes schema with clean slate (0 presets) and default app settings', () async {
      final categories = await dbHelper.getAllCategories();
      expect(categories.length, equals(0)); // Presets removed

      final templates = await dbHelper.getAllTemplates();
      expect(templates.length, equals(0)); // Presets removed

      final currency = await dbHelper.getSetting('currency_symbol');
      expect(currency, equals('₹'));

      final cycleStartDay = await dbHelper.getSetting('cycle_start_day');
      expect(cycleStartDay, equals('1'));
    });

    test('Allows inserting custom categories and querying by type', () async {
      await dbHelper.insertCategory(const CategoryModel(
        name: 'Groceries',
        budgetLimit: 5000.0,
        type: CategoryType.expense,
      ));
      await dbHelper.insertCategory(const CategoryModel(
        name: 'Emergency Fund',
        budgetLimit: 10000.0,
        type: CategoryType.investment,
      ));

      final expenses = await dbHelper.getCategoriesByType(CategoryType.expense);
      expect(expenses.length, equals(1));
      expect(expenses.first.name, equals('Groceries'));

      final investments = await dbHelper.getCategoriesByType(CategoryType.investment);
      expect(investments.length, equals(1));
      expect(investments.first.name, equals('Emergency Fund'));
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
        source: 'Freelance Design',
        amount: 15000.0,
        cycleMonth: '2026-11',
        createdAt: now + 1000,
      ));
      await dbHelper.insertIncome(IncomeModel(
        source: 'Previous Month Salary',
        amount: 80000.0,
        cycleMonth: '2026-10',
        createdAt: now - 30 * 86400000,
      ));

      final incomesNov = await dbHelper.getIncomesForMonth('2026-11');
      expect(incomesNov.length, equals(2));

      final totalNov = await dbHelper.getTotalIncomeForMonth('2026-11');
      expect(totalNov, equals(100000.0));

      final totalOct = await dbHelper.getTotalIncomeForMonth('2026-10');
      expect(totalOct, equals(80000.0));
    });

    test('Inserts transactions and calculates category spent per cycle month', () async {
      final foodCatId = await dbHelper.insertCategory(const CategoryModel(
        name: 'Food & Dining',
        budgetLimit: 5000.0,
        type: CategoryType.expense,
      ));
      final travelCatId = await dbHelper.insertCategory(const CategoryModel(
        name: 'Travel & Commute',
        budgetLimit: 3000.0,
        type: CategoryType.expense,
      ));

      final now = DateTime.now().millisecondsSinceEpoch;

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCatId,
        amount: 450.0,
        description: 'Lunch',
        cycleMonth: '2026-11',
        createdAt: now,
      ));

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCatId,
        amount: 850.0,
        description: 'Groceries',
        cycleMonth: '2026-11',
        createdAt: now + 500,
      ));

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: travelCatId,
        amount: 200.0,
        description: 'Metro',
        cycleMonth: '2026-11',
        createdAt: now + 1000,
      ));

      final foodSpent = await dbHelper.getCategorySpentForMonth(foodCatId, '2026-11');
      expect(foodSpent, equals(1300.0));

      final travelSpent = await dbHelper.getCategorySpentForMonth(travelCatId, '2026-11');
      expect(travelSpent, equals(200.0));

      final allNovTxs = await dbHelper.getTransactionsForMonth('2026-11');
      expect(allNovTxs.length, equals(3));
    });

    test('Enforces foreign key constraint on deleting category with active transactions', () async {
      final foodCatId = await dbHelper.insertCategory(const CategoryModel(
        name: 'Food & Dining',
        budgetLimit: 5000.0,
        type: CategoryType.expense,
      ));

      await dbHelper.insertTransaction(TransactionModel(
        categoryId: foodCatId,
        amount: 300.0,
        description: 'Snacks',
        cycleMonth: '2026-11',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

      // Attempting to delete category should fail due to ON DELETE RESTRICT
      expect(
        () async => await dbHelper.deleteCategory(foodCatId),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Manages recurring templates and goals CRUD operations', () async {
      final rentCatId = await dbHelper.insertCategory(const CategoryModel(
        name: 'House Rent',
        budgetLimit: 22000.0,
        type: CategoryType.expense,
      ));

      // 1. Template
      final templateId = await dbHelper.insertTemplate(TemplateModel(
        title: 'Monthly Rent',
        categoryId: rentCatId,
        defaultAmount: 22000.0,
        defaultDescription: 'Apartment Rent',
      ));
      expect(templateId, greaterThan(0));

      final templates = await dbHelper.getAllTemplates();
      expect(templates.length, equals(1));
      expect(templates.first.title, equals('Monthly Rent'));

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

    test('resetToScratch clears all tables completely', () async {
      final catId = await dbHelper.insertCategory(const CategoryModel(
        name: 'Sample',
        budgetLimit: 1000.0,
        type: CategoryType.expense,
      ));
      await dbHelper.insertTransaction(TransactionModel(
        categoryId: catId,
        amount: 100.0,
        cycleMonth: '2026-11',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      await dbHelper.insertIncome(IncomeModel(
        source: 'Income',
        amount: 1000.0,
        cycleMonth: '2026-11',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

      await dbHelper.resetToScratch();

      expect((await dbHelper.getAllCategories()).length, equals(0));
      expect((await dbHelper.getTransactionsForMonth('2026-11')).length, equals(0));
      expect((await dbHelper.getIncomesForMonth('2026-11')).length, equals(0));
    });
  });
}
