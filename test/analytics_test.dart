import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/features/analytics/analytics_screen.dart';
import 'package:finance_tracker/features/analytics/donut_chart.dart';
import 'package:finance_tracker/features/budget/budget_controller.dart';
import 'package:finance_tracker/features/budget/budget_repository.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('Phase 4: Analytics & Lifetime Metrics Engine Tests', () {
    late DatabaseHelper dbHelper;
    late BudgetController controller;
    late String dbName;

    setUp(() async {
      dbName = 'test_analytics_unit_${DateTime.now().microsecondsSinceEpoch}.db';
      dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      await dbHelper.database;
      controller = BudgetController(BudgetRepository(dbHelper));
      await controller.loadBudgetData('2026-11');
    });

    tearDown(() async {
      await dbHelper.close();
      await databaseFactoryFfi.deleteDatabase(dbName);
    });

    test('Calculates Net Flow Split percentages accurately', () async {
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 0, type: CategoryType.expense);
      await controller.createCategory(name: 'SIP & Mutual Funds', budgetLimit: 0, type: CategoryType.investment);

      // Total Inflow = 100,000
      await controller.addIncome(source: 'Salary', amount: 100000.0);

      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      final sipCat = controller.categories.firstWhere((c) => c.name == 'SIP & Mutual Funds');

      // Burn 40,000 (40%)
      await controller.recordTransaction(categoryId: foodCat.id!, amount: 40000.0);
      // Invest 30,000 (30%)
      await controller.recordTransaction(categoryId: sipCat.id!, amount: 30000.0);

      // Remaining unspent = 30,000 (30%)
      expect(controller.totalInflow, equals(100000.0));
      expect(controller.totalBurned, equals(40000.0));
      expect(controller.totalInvested, equals(30000.0));
      expect(controller.unspentBalance, equals(30000.0));

      expect(controller.burnPercentage, equals(40.0));
      expect(controller.investPercentage, equals(30.0));
      expect(controller.unspentPercentage, equals(30.0));
    });

    test('Calculates Lifetime cumulative metrics across multiple monthly cycles', () async {
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 0, type: CategoryType.expense);
      await controller.createCategory(name: 'SIP & Mutual Funds', budgetLimit: 0, type: CategoryType.investment);

      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      final sipCat = controller.categories.firstWhere((c) => c.name == 'SIP & Mutual Funds');

      // Month 1: 2026-10
      await controller.switchCycleMonth('2026-10');
      await controller.addIncome(source: 'Oct Salary', amount: 80000.0);
      await controller.recordTransaction(categoryId: foodCat.id!, amount: 25000.0, description: 'Oct Expenses');
      await controller.recordTransaction(categoryId: sipCat.id!, amount: 20000.0, description: 'Oct SIP');

      // Month 2: 2026-11
      await controller.switchCycleMonth('2026-11');
      await controller.addIncome(source: 'Nov Salary', amount: 85000.0);
      await controller.recordTransaction(categoryId: foodCat.id!, amount: 30000.0, description: 'Nov Expenses');
      await controller.recordTransaction(categoryId: sipCat.id!, amount: 25000.0, description: 'Nov SIP');

      // Cumulative Lifetime checks:
      // Lifetime Inflow = 80k + 85k = 165,000
      expect(controller.lifetimeInflow, equals(165000.0));
      // Lifetime Burned = 25k + 30k = 55,000
      expect(controller.lifetimeBurned, equals(55000.0));
      // Lifetime Invested = 20k + 25k = 45,000
      expect(controller.lifetimeInvested, equals(45000.0));
      // Lifetime Saved = 165k - (55k + 45k) = 65,000
      expect(controller.lifetimeSaved, equals(65000.0));
      // Lifetime Months Count = 2
      expect(controller.lifetimeMonthsCount, equals(2));
    });
  });

  group('Phase 4: Widget & Interaction Tests', () {
    testWidgets('CustomDonutChart renders slices and updates center on slice selection', (WidgetTester tester) async {
      const slices = [
        DonutSlice(label: 'Burned', amount: 32000, color: Colors.red, percentage: 40),
        DonutSlice(label: 'Invested', amount: 48000, color: Colors.green, percentage: 60),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomDonutChart(
              slices: slices,
              defaultTitle: 'Net Inflow',
              totalAmount: 80000,
              currencySymbol: '₹',
              defaultSubtitle: '100% Inflow',
            ),
          ),
        ),
      );
      await tester.pump();

      // Check default center readout
      expect(find.text('NET INFLOW'), findsOneWidget);
      expect(find.text('₹80,000'), findsOneWidget);
      expect(find.text('100% Inflow'), findsOneWidget);

      // Check legend chips
      expect(find.text('Burned'), findsOneWidget);
      expect(find.text('Invested'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);

      // Tap on 'Invested' legend chip
      await tester.tap(find.text('Invested'));
      await tester.pump();

      // Center should now display 'INVESTED', '₹48,000', and 60%
      expect(find.text('INVESTED'), findsOneWidget);
      expect(find.text('₹48,000'), findsOneWidget);
      expect(find.text('60%'), findsNWidgets(2)); // 1 in legend, 1 in center
    });

    testWidgets('AnalyticsScreen renders carousel, lifetime card, and filters transactions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final dbName = 'test_widget_analytics_${DateTime.now().microsecondsSinceEpoch}.db';
      final dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      final controller = BudgetController(BudgetRepository(dbHelper));

      // Populate test data inside runAsync
      await tester.runAsync(() async {
        await controller.loadBudgetData('2026-11');
        await controller.createCategory(name: 'Food & Dining', budgetLimit: 0, type: CategoryType.expense);
        await controller.createCategory(name: 'SIP & Mutual Funds', budgetLimit: 0, type: CategoryType.investment);
        await controller.addIncome(source: 'Salary', amount: 80000.0);
        final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
        final sipCat = controller.categories.firstWhere((c) => c.name == 'SIP & Mutual Funds');

        await controller.recordTransaction(categoryId: foodCat.id!, amount: 5000.0, description: 'Groceries');
        await controller.recordTransaction(categoryId: sipCat.id!, amount: 15000.0, description: 'SIP Deposit');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(controller: controller),
        ),
      );
      await tester.pump();

      // Verify Header
      expect(find.text('INFOGRAPHICS & METRICS'), findsOneWidget);
      expect(find.text('Financial Analytics'), findsOneWidget);

      // Verify Carousel initial page: Net Flow Split
      expect(find.text('Net Flow Split'), findsOneWidget);

      // Verify Lifetime card
      expect(find.text('LIFETIME'), findsOneWidget);
      expect(find.text('INVESTED'), findsOneWidget);
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('BURNED'), findsOneWidget);

      // Verify Transaction Feed with both items visible initially (All filter)
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('SIP Deposit'), findsOneWidget);

      // Tap "Expenses" filter chip
      await tester.tap(find.text('Expenses'));
      await tester.pump();

      // Only Groceries should remain visible, SIP Deposit should be filtered out
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('SIP Deposit'), findsNothing);

      // Tap "Investments" filter chip
      await tester.tap(find.text('Investments'));
      await tester.pump();

      // Only SIP Deposit should remain visible, Groceries filtered out
      expect(find.text('SIP Deposit'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);

      // Clean up using runAsync so native FFI calls complete cleanly
      await tester.runAsync(() async {
        await dbHelper.close();
        await databaseFactoryFfi.deleteDatabase(dbName);
      });
    });
  });
}
