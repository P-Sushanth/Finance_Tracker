import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/budget_controller.dart';
import 'features/budget/budget_repository.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database factory based on platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize SQLite database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  final controller = BudgetController(BudgetRepository(dbHelper));
  await controller.loadBudgetData();

  runApp(FinanceTrackerApp(controller: controller));
}

class FinanceTrackerApp extends StatefulWidget {
  final BudgetController? controller;
  final DatabaseHelper? dbHelper;

  const FinanceTrackerApp({
    super.key,
    this.controller,
    this.dbHelper,
  });

  @override
  State<FinanceTrackerApp> createState() => _FinanceTrackerAppState();
}

class _FinanceTrackerAppState extends State<FinanceTrackerApp> {
  late final BudgetController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      final helper = widget.dbHelper ?? DatabaseHelper();
      _controller = BudgetController(BudgetRepository(helper));
      _controller.loadBudgetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: MainShell(controller: _controller),
    );
  }
}
