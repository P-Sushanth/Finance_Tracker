import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/features/budget/budget_controller.dart';
import 'package:finance_tracker/features/budget/budget_repository.dart';
import 'package:finance_tracker/shared/models/category_model.dart';

void main() {
  sqfliteFfiInit();

  group('BudgetController & Phase 2 Core Engine Tests', () {
    late DatabaseHelper dbHelper;
    late BudgetController controller;

    setUp(() async {
      final dbName = 'budget_test_${DateTime.now().microsecondsSinceEpoch}.db';
      dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      controller = BudgetController(BudgetRepository(dbHelper));
      await controller.loadBudgetData('2026-11');
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Initializes with 0 presets (clean slate) and initial zero balances', () {
      expect(controller.categories.length, equals(0));
      expect(controller.expenseCategories.length, equals(0));
      expect(controller.investmentCategories.length, equals(0));
      expect(controller.totalInflow, equals(0.0));
      expect(controller.totalBurned, equals(0.0));
      expect(controller.totalInvested, equals(0.0));
      expect(controller.unspentBalance, equals(0.0));
    });

    test('Adds cash inflow and updates totalInflow and unspent balance', () async {
      await controller.addIncome(source: 'Monthly Salary', amount: 85000.0);
      expect(controller.totalInflow, equals(85000.0));
      expect(controller.unspentBalance, equals(85000.0));
      expect(controller.incomes.length, equals(1));

      await controller.addIncome(source: 'Freelance', amount: 15000.0);
      expect(controller.totalInflow, equals(100000.0));
      expect(controller.unspentBalance, equals(100000.0));
      expect(controller.incomes.length, equals(2));
    });

    test('Modifies category budget limit and verifies allocated totals', () async {
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 0, type: CategoryType.expense);
      await controller.createCategory(name: 'House Rent', budgetLimit: 0, type: CategoryType.expense);

      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      final rentCat = controller.categories.firstWhere((c) => c.name == 'House Rent');

      await controller.updateCategoryBudget(foodCat.id!, 12000.0);
      await controller.updateCategoryBudget(rentCat.id!, 22000.0);

      final updatedFood = controller.findCategoryById(foodCat.id!);
      expect(updatedFood?.budgetLimit, equals(12000.0));

      final updatedRent = controller.findCategoryById(rentCat.id!);
      expect(updatedRent?.budgetLimit, equals(22000.0));

      expect(controller.totalAllocatedBudget, equals(34000.0));
    });

    test('Records transaction and immediately deducts from category budget', () async {
      await controller.addIncome(source: 'Salary', amount: 50000.0);
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 10000.0, type: CategoryType.expense);
      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');

      // 1. Transaction within budget
      await controller.recordTransaction(
        categoryId: foodCat.id!,
        amount: 3500.0,
        description: 'Weekly Groceries',
      );

      final food = controller.findCategoryById(foodCat.id!)!;
      expect(controller.getCategorySpent(food.id!), equals(3500.0));
      expect(controller.getCategoryRemaining(food), equals(6500.0));
      expect(controller.totalBurned, equals(3500.0));
      expect(controller.unspentBalance, equals(46500.0));

      // 2. Overbudget transaction
      await controller.recordTransaction(
        categoryId: foodCat.id!,
        amount: 7000.0,
        description: 'Fine Dining Event',
      );

      expect(controller.getCategorySpent(food.id!), equals(10500.0));
      // Remaining is now negative (overbudget)
      expect(controller.getCategoryRemaining(food), equals(-500.0));
      expect(controller.totalBurned, equals(10500.0));
      expect(controller.unspentBalance, equals(39500.0));
    });

    test('Differentiates between Expense outflow and Investment asset growth', () async {
      await controller.addIncome(source: 'Salary', amount: 80000.0);
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 0, type: CategoryType.expense);
      await controller.createCategory(name: 'SIP & Mutual Funds', budgetLimit: 0, type: CategoryType.investment);

      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      final sipCat = controller.categories.firstWhere((c) => c.name == 'SIP & Mutual Funds');

      await controller.recordTransaction(
        categoryId: foodCat.id!,
        amount: 20000.0,
        description: 'Food Expenses',
      );

      await controller.recordTransaction(
        categoryId: sipCat.id!,
        amount: 30000.0,
        description: 'Index SIP',
      );

      expect(controller.totalBurned, equals(20000.0));
      expect(controller.totalInvested, equals(30000.0));
      expect(controller.unspentBalance, equals(30000.0));

      expect(controller.burnPercentage, equals(25.0)); // 20k / 80k = 25%
      expect(controller.investPercentage, equals(37.5)); // 30k / 80k = 37.5%
      expect(controller.unspentPercentage, equals(37.5)); // 30k / 80k = 37.5%
    });

    test('Creates goals and deposits savings toward goal', () async {
      await controller.createGoal(
        title: 'Emergency Corpus',
        targetAmount: 150000.0,
        monthlyBudgetAllocation: 10000.0,
      );

      expect(controller.goals.length, equals(1));
      final goal = controller.goals.first;
      expect(goal.title, equals('Emergency Corpus'));
      expect(goal.targetAmount, equals(150000.0));
      expect(goal.currentSaved, equals(0.0));

      await controller.addSavingsToGoal(goal.id!, 25000.0);

      final updatedGoals = controller.goals;
      expect(updatedGoals.first.currentSaved, equals(25000.0));
    });
  });
}
