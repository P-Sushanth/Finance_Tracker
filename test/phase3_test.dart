import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/core/utils/date_helpers.dart';
import 'package:finance_tracker/features/budget/budget_controller.dart';
import 'package:finance_tracker/features/budget/budget_repository.dart';
import 'package:finance_tracker/features/quick_add/quick_add_sheet.dart';
import 'package:finance_tracker/features/templates/templates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('Phase 3: Recurring Templates & Monthly Reset Engine Tests', () {
    late DatabaseHelper dbHelper;
    late BudgetController controller;
    late String dbName;

    setUp(() async {
      dbName = 'test_phase3_unit_${DateTime.now().microsecondsSinceEpoch}.db';
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

    test('Seeded recurring templates are loaded into state', () {
      expect(controller.templates.length, equals(3));
      final rent = controller.templates.firstWhere((t) => t.title == 'Monthly House Rent');
      expect(rent.defaultAmount, equals(22000.0));

      final sip = controller.templates.firstWhere((t) => t.title == 'Nifty 50 Index SIP');
      expect(sip.defaultAmount, equals(15000.0));

      final wifi = controller.templates.firstWhere((t) => t.title == 'Fiber WiFi Bill');
      expect(wifi.defaultAmount, equals(999.0));
    });

    test('Template CRUD operations work seamlessly', () async {
      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');

      // 1. Create Template
      await controller.createTemplate(
        title: 'Weekly Meal Prep',
        categoryId: foodCat.id!,
        defaultAmount: 2500.0,
        defaultDescription: 'Groceries and veggies',
      );

      expect(controller.templates.length, equals(4));
      final newTemplate = controller.templates.firstWhere((t) => t.title == 'Weekly Meal Prep');
      expect(newTemplate.defaultAmount, equals(2500.0));

      // 2. Update Template
      final updated = newTemplate.copyWith(
        title: 'Weekly Gourmet Prep',
        defaultAmount: 3200.0,
      );
      await controller.updateTemplate(updated);

      final fetched = controller.templates.firstWhere((t) => t.id == newTemplate.id);
      expect(fetched.title, equals('Weekly Gourmet Prep'));
      expect(fetched.defaultAmount, equals(3200.0));

      // 3. Delete Template
      await controller.deleteTemplate(newTemplate.id!);
      expect(controller.templates.length, equals(3));
      expect(controller.templates.any((t) => t.id == newTemplate.id), isFalse);
    });

    test('1-Tap Apply Template logs transaction immediately to active cycle', () async {
      final rentTemplate = controller.templates.firstWhere((t) => t.title == 'Monthly House Rent');

      expect(controller.transactions.length, equals(0));
      expect(controller.totalBurned, equals(0.0));

      // Apply the rent template (₹22,000)
      await controller.applyTemplate(rentTemplate);

      expect(controller.transactions.length, equals(1));
      expect(controller.transactions.first.amount, equals(22000.0));
      expect(controller.transactions.first.categoryId, equals(rentTemplate.categoryId));
      expect(controller.transactions.first.cycleMonth, equals('2026-11'));
      expect(controller.totalBurned, equals(22000.0));
    });

    test('Monthly cycle switcher isolates past months and resets current month balances', () async {
      // 1. Log data in 2026-11
      await controller.addIncome(source: 'Salary', amount: 80000.0);
      final utilCat = controller.categories.firstWhere((c) => c.name == 'Utilities');
      await controller.recordTransaction(categoryId: utilCat.id!, amount: 1500.0, description: 'Power');

      expect(controller.currentCycleMonth, equals('2026-11'));
      expect(controller.totalInflow, equals(80000.0));
      expect(controller.totalBurned, equals(1500.0));
      expect(controller.unspentBalance, equals(78500.0));

      // 2. Switch to 2026-10 (Past Cycle)
      await controller.switchCycleMonth('2026-10');
      expect(controller.currentCycleMonth, equals('2026-10'));
      expect(controller.incomes.length, equals(0));
      expect(controller.transactions.length, equals(0));
      expect(controller.totalInflow, equals(0.0));
      expect(controller.totalBurned, equals(0.0));
      expect(controller.unspentBalance, equals(0.0));

      // 3. Log a past transaction in 2026-10
      await controller.addIncome(source: 'Oct Salary', amount: 75000.0);
      await controller.recordTransaction(categoryId: utilCat.id!, amount: 1200.0, description: 'Oct Power');
      expect(controller.totalInflow, equals(75000.0));
      expect(controller.totalBurned, equals(1200.0));

      // 4. Switch back to 2026-11
      await controller.switchCycleMonth('2026-11');
      expect(controller.currentCycleMonth, equals('2026-11'));
      expect(controller.totalInflow, equals(80000.0));
      expect(controller.totalBurned, equals(1500.0));
      expect(controller.transactions.first.description, equals('Power'));

      // 5. Verify recorded cycle months contains both
      final recorded = controller.recordedCycleMonths;
      expect(recorded.contains('2026-11'), isTrue);
      expect(recorded.contains('2026-10'), isTrue);
    });

    test('Cycle start day setting persists and calculates cycles accurately', () async {
      expect(controller.cycleStartDay, equals(1));

      // Set salary cycle start day to 25th
      await controller.setCycleStartDay(25);
      expect(controller.cycleStartDay, equals(25));

      // Test DateHelpers logic with day 25
      final beforePayday = DateTime(2026, 11, 20); // Nov 20 belongs to Oct cycle (started Oct 25)
      final afterPayday = DateTime(2026, 11, 26);  // Nov 26 belongs to Nov cycle (started Nov 25)

      expect(DateHelpers.getCycleMonthForDate(beforePayday, 25), equals('2026-10'));
      expect(DateHelpers.getCycleMonthForDate(afterPayday, 25), equals('2026-11'));
    });
  });

  group('Phase 3: Widgets & Interaction Tests', () {
    testWidgets('QuickAddSheet logs outflow via custom keypad and category chips', (WidgetTester tester) async {
      final dbName = 'test_widget_qa_out_${DateTime.now().microsecondsSinceEpoch}.db';
      final dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      final controller = BudgetController(BudgetRepository(dbHelper));

      await tester.runAsync(() async {
        await controller.loadBudgetData('2026-11');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuickAddSheet(controller: controller),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify initial Outflow mode is active
      expect(find.text('Outflow'), findsOneWidget);
      expect(find.text('Inflow'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);

      // Press '5', '0', '0' on numeric keypad
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();

      expect(find.text('₹ 500'), findsOneWidget);

      // Tap "Record Outflow"
      await tester.runAsync(() async {
        await tester.tap(find.text('Record Outflow'));
        await tester.pump();
        for (int i = 0; i < 20 && controller.transactions.isEmpty; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pump();

      // Verify transaction recorded
      expect(controller.transactions.length, equals(1));
      expect(controller.transactions.first.amount, equals(500.0));

      await tester.runAsync(() async {
        await dbHelper.close();
        await databaseFactoryFfi.deleteDatabase(dbName);
      });
    });

    testWidgets('QuickAddSheet switches to Inflow mode and removes category chips', (WidgetTester tester) async {
      final dbName = 'test_widget_qa_in_${DateTime.now().microsecondsSinceEpoch}.db';
      final dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      final controller = BudgetController(BudgetRepository(dbHelper));

      await tester.runAsync(() async {
        await controller.loadBudgetData('2026-11');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuickAddSheet(controller: controller),
            ),
          ),
        ),
      );
      await tester.pump();

      // Switch to Inflow mode
      await tester.tap(find.text('Inflow'));
      await tester.pump();

      // Inflow must NOT require or show category chips
      expect(find.text('Food & Dining'), findsNothing);
      expect(find.text('Record Inflow'), findsOneWidget);

      // Enter amount: '4', '0', '0', '0'
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();

      expect(find.text('₹ 4000'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('Record Inflow'));
        await tester.pump();
        for (int i = 0; i < 20 && controller.incomes.isEmpty; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pump();

      // Verify Inflow recorded
      expect(controller.incomes.length, equals(1));
      expect(controller.totalInflow, equals(4000.0));

      await tester.runAsync(() async {
        await dbHelper.close();
        await databaseFactoryFfi.deleteDatabase(dbName);
      });
    });

    testWidgets('TemplatesScreen renders presets and applies template with 1 tap', (WidgetTester tester) async {
      final dbName = 'test_widget_tpl_${DateTime.now().microsecondsSinceEpoch}.db';
      final dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      final controller = BudgetController(BudgetRepository(dbHelper));

      await tester.runAsync(() async {
        await controller.loadBudgetData('2026-11');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TemplatesScreen(controller: controller),
        ),
      );
      await tester.pump();

      // Verify seeded templates are displayed
      expect(find.text('Monthly House Rent'), findsOneWidget);
      expect(find.text('Nifty 50 Index SIP'), findsOneWidget);
      expect(find.text('Fiber WiFi Bill'), findsOneWidget);

      // Find "Apply Now" buttons (3 buttons for 3 templates)
      final applyButtons = find.text('Apply Now');
      expect(applyButtons, findsNWidgets(3));

      // Tap the first "Apply Now" (Monthly House Rent)
      await tester.runAsync(() async {
        await tester.tap(applyButtons.first);
        await tester.pump();
        for (int i = 0; i < 20 && controller.transactions.isEmpty; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pump();

      // Verify transaction was applied
      expect(controller.transactions.length, equals(1));
      expect(controller.transactions.first.amount, equals(22000.0));
      expect(controller.totalBurned, equals(22000.0));

      await tester.runAsync(() async {
        await dbHelper.close();
        await databaseFactoryFfi.deleteDatabase(dbName);
      });
    });
  });
}
