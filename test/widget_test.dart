import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/features/budget/budget_controller.dart';
import 'package:finance_tracker/features/budget/budget_repository.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late BudgetController controller;

  setUp(() async {
    sqfliteFfiInit();
    dbHelper = DatabaseHelper.withFactory(
      factory: databaseFactoryFfi,
      customPath: inMemoryDatabasePath,
    );
    await dbHelper.database;
    controller = BudgetController(BudgetRepository(dbHelper));
    await controller.loadBudgetData('2026-11');
  });

  tearDown(() async {
    await dbHelper.close();
  });

  testWidgets('FinanceTrackerApp renders Phase 2 MainShell with HomeScreen and Envelopes', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 5000.0, type: CategoryType.expense);
      await controller.createCategory(name: 'Travel & Commute', budgetLimit: 3000.0, type: CategoryType.expense);
      await controller.createCategory(name: 'SIP & Mutual Funds', budgetLimit: 15000.0, type: CategoryType.investment);
      await controller.createCategory(name: 'Emergency Fund', budgetLimit: 10000.0, type: CategoryType.investment);
      await tester.pumpWidget(FinanceTrackerApp(controller: controller));
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pump();

    // Verify Month Header and Balance Card
    expect(find.text('MONTHLY CYCLE'), findsOneWidget);
    expect(find.text('TOTAL INFLOW'), findsOneWidget);
    expect(find.text('UNSPENT'), findsOneWidget);

    // Verify 2-Page Segmented Tab (Expenses & Growth)
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);

    // Verify Default Expense Category Cards visible
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Travel & Commute'), findsOneWidget);

    // Switch to Growth tab
    await tester.tap(find.text('Growth'));
    await tester.pump();

    // Verify Growth envelopes appear
    expect(find.text('SIP & Mutual Funds'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);

    // Switch to Goals screen via bottom dock (target bullseye icon)
    await tester.tap(find.byIcon(Icons.track_changes_rounded));
    await tester.pump();

    expect(find.text('Goals & Targets'), findsOneWidget);
    expect(find.text('TOTAL SAVED FOR GOALS'), findsOneWidget);
  });
}
