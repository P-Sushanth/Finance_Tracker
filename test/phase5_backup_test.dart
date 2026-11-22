import 'dart:convert';
import 'package:finance_tracker/core/database/database_helper.dart';
import 'package:finance_tracker/features/backup/backup_service.dart';
import 'package:finance_tracker/features/backup/update_service.dart';
import 'package:finance_tracker/features/budget/budget_controller.dart';
import 'package:finance_tracker/features/budget/budget_repository.dart';
import 'package:finance_tracker/features/settings/settings_screen.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('Phase 5: Data Safety & Backup/Restore Unit Tests', () {
    late DatabaseHelper dbHelper;
    late BudgetRepository repository;
    late BudgetController controller;
    late BackupService backupService;
    late String dbName;

    setUp(() async {
      dbName = 'test_backup_unit_${DateTime.now().microsecondsSinceEpoch}.db';
      dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      await dbHelper.database;
      repository = BudgetRepository(dbHelper);
      controller = BudgetController(repository);
      backupService = BackupService(repository);
      await controller.loadBudgetData('2026-11');
    });

    tearDown(() async {
      await dbHelper.close();
      await databaseFactoryFfi.deleteDatabase(dbName);
    });

    test('Export produces valid JSON schema with all required tables', () async {
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 10000.0, type: CategoryType.expense);
      await controller.addIncome(source: 'Primary Salary', amount: 95000.0);
      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      await controller.recordTransaction(
        categoryId: foodCat.id!,
        amount: 3200.0,
        description: 'Supermarket shopping',
      );

      final jsonBackup = await backupService.generateJsonBackup();
      expect(jsonBackup, isNotEmpty);

      final Map<String, dynamic> decoded = json.decode(jsonBackup);
      expect(decoded['version'], equals(1));
      expect(decoded['app'], equals('FinanceTracker'));
      expect(decoded.containsKey('exported_at'), isTrue);

      final data = decoded['data'] as Map<String, dynamic>;
      expect(data.containsKey('categories'), isTrue);
      expect(data.containsKey('incomes'), isTrue);
      expect(data.containsKey('transactions'), isTrue);
      expect(data.containsKey('templates'), isTrue);
      expect(data.containsKey('goals'), isTrue);
      expect(data.containsKey('app_settings'), isTrue);

      final incomes = data['incomes'] as List;
      expect(incomes.length, equals(1));
      expect(incomes.first['amount'], equals(95000.0));

      final txs = data['transactions'] as List;
      expect(txs.length, equals(1));
      expect(txs.first['amount'], equals(3200.0));
      expect(txs.first['description'], equals('Supermarket shopping'));
    });

    test('Export produces spreadsheet-compatible CSV formatted transactions', () async {
      await controller.createCategory(name: 'Utilities', budgetLimit: 5000.0, type: CategoryType.expense);
      final utilCat = controller.categories.firstWhere((c) => c.name == 'Utilities');
      await controller.recordTransaction(
        categoryId: utilCat.id!,
        amount: 1450.0,
        description: 'Electricity Bill',
      );

      final csvExport = await backupService.generateCsvExport();
      expect(csvExport, isNotEmpty);

      final lines = csvExport.trim().split('\n');
      expect(lines.first.trim(), equals('ID,Date,Time,Category,Type,Amount,Description,CycleMonth'));
      expect(lines.length, equals(2)); // Header + 1 transaction row
      expect(lines[1].contains('Utilities'), isTrue);
      expect(lines[1].contains('1450.0'), isTrue);
      expect(lines[1].contains('"Electricity Bill"'), isTrue);
      expect(lines[1].contains('2026-11'), isTrue);
    });

    test('Restore completely repopulates database tables from JSON backup', () async {
      // 1. Log rich state in database
      await controller.createCategory(name: 'Food & Dining', budgetLimit: 10000.0, type: CategoryType.expense);
      await controller.addIncome(source: 'Initial Salary', amount: 80000.0);
      final foodCat = controller.categories.firstWhere((c) => c.name == 'Food & Dining');
      await controller.recordTransaction(categoryId: foodCat.id!, amount: 4500.0, description: 'Dining');
      await controller.createGoal(title: 'New Laptop', targetAmount: 90000.0);

      expect(controller.incomes.length, equals(1));
      expect(controller.transactions.length, equals(1));
      expect(controller.goals.length, equals(1));

      // 2. Export backup
      final backupJson = await backupService.generateJsonBackup();

      // 3. Clear/corrupt state by adding and deleting records
      await controller.deleteTransaction(controller.transactions.first.id!);
      await controller.createCategory(name: 'Temporary Cat', budgetLimit: 500, type: CategoryType.expense);
      expect(controller.transactions.length, equals(0));

      // 4. Restore from backup
      final success = await backupService.restoreFromJsonString(backupJson, controller);
      expect(success, isTrue);

      // 5. Verify restored state
      expect(controller.incomes.length, equals(1));
      expect(controller.incomes.first.source, equals('Initial Salary'));
      expect(controller.transactions.length, equals(1));
      expect(controller.transactions.first.amount, equals(4500.0));
      expect(controller.transactions.first.description, equals('Dining'));
      expect(controller.goals.length, equals(1));
      expect(controller.goals.first.title, equals('New Laptop'));
      expect(controller.categories.any((c) => c.name == 'Temporary Cat'), isFalse);
    });
  });

  group('Phase 5: In-App Update Service Tests', () {
    test('Detects available update when remote version_code is greater', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'version_code': 2,
            'version_name': '1.1.0',
            'apk_url': 'https://github.com/personal/finance_tracker/releases/download/v1.1.0/app-release.apk',
            'release_notes': 'Added new investment infographics and fast CSV export.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final updateService = UpdateService(mockClient);
      final updateInfo = await updateService.checkForUpdate();

      expect(updateInfo.currentVersionCode, equals(1));
      expect(updateInfo.latestVersionCode, equals(2));
      expect(updateInfo.latestVersionName, equals('1.1.0'));
      expect(updateInfo.isUpdateAvailable, isTrue);
      expect(updateInfo.apkUrl, contains('app-release.apk'));
      expect(updateInfo.releaseNotes, contains('Added new investment infographics'));
    });

    test('Confirms app is up to date when remote version_code is equal', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'version_code': 1,
            'version_name': '1.0.0',
            'apk_url': 'https://github.com/personal/finance_tracker/releases/download/v1.0.0/app-release.apk',
            'release_notes': 'Initial release.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final updateService = UpdateService(mockClient);
      final updateInfo = await updateService.checkForUpdate();

      expect(updateInfo.currentVersionCode, equals(1));
      expect(updateInfo.latestVersionCode, equals(1));
      expect(updateInfo.isUpdateAvailable, isFalse);
    });
  });

  group('Phase 5: SettingsScreen Widget Tests', () {
    testWidgets('SettingsScreen renders backup actions, cycle preferences, and update checks', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final dbName = 'test_widget_settings_${DateTime.now().microsecondsSinceEpoch}.db';
      final dbHelper = DatabaseHelper.withFactory(
        factory: databaseFactoryFfi,
        customPath: dbName,
      );
      final repository = BudgetRepository(dbHelper);
      final controller = BudgetController(repository);

      await tester.runAsync(() async {
        await controller.loadBudgetData('2026-11');
      });

      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'version_code': 2,
            'version_name': '1.2.0',
            'apk_url': 'https://github.com/personal/finance_tracker/releases/download/v1.2.0/app-release.apk',
            'release_notes': 'Bug fixes and performance improvements.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final updateService = UpdateService(mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            controller: controller,
            updateService: updateService,
          ),
        ),
      );
      await tester.pump();

      // Verify Screen Title and Sections
      expect(find.text('Settings & Data Safety'), findsOneWidget);
      expect(find.text('DATA SOVEREIGNTY & BACKUP'), findsOneWidget);
      expect(find.text('Export JSON Backup'), findsOneWidget);
      expect(find.text('Export CSV Transactions'), findsOneWidget);
      expect(find.text('Restore Backup (JSON)'), findsOneWidget);

      // Verify Preferences & Cycle
      expect(find.text('PREFERENCES & CYCLE'), findsOneWidget);
      expect(find.text('Cycle Reset Day'), findsOneWidget);

      // Verify Updates & Check Updates button
      expect(find.text('APP UPDATES'), findsOneWidget);
      expect(find.text('Check Updates'), findsOneWidget);

      // Tap "Check Updates" button
      await tester.runAsync(() async {
        await tester.tap(find.text('Check Updates'));
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // Verify Update Available Dialog appears
      expect(find.text('Update Available'), findsOneWidget);
      expect(find.text('Download APK'), findsOneWidget);

      await tester.runAsync(() async {
        await dbHelper.close();
        await databaseFactoryFfi.deleteDatabase(dbName);
      });
    });
  });
}
