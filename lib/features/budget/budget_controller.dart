import 'package:flutter/foundation.dart';
import '../../core/utils/date_helpers.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/income_model.dart';
import '../../shared/models/template_model.dart';
import '../../shared/models/transaction_model.dart';
import 'budget_repository.dart';

class BudgetController extends ChangeNotifier {
  final BudgetRepository _repository;

  String _currentCycleMonth = DateHelpers.getCurrentCycleMonth();
  int _cycleStartDay = 1;
  bool _isLoading = true;

  List<IncomeModel> _incomes = [];
  List<CategoryModel> _categories = [];
  List<TransactionModel> _transactions = [];
  List<GoalModel> _goals = [];
  List<TemplateModel> _templates = [];
  List<String> _recordedCycleMonths = [];
  final Map<int, double> _categorySpentMap = {};

  double _lifetimeInflow = 0.0;
  double _lifetimeBurned = 0.0;
  double _lifetimeInvested = 0.0;
  int _lifetimeMonthsCount = 1;

  String _currencySymbol = '₹';

  BudgetController([BudgetRepository? repository])
      : _repository = repository ?? BudgetRepository();

  // Getters
  bool get isLoading => _isLoading;
  String get currentCycleMonth => _currentCycleMonth;
  int get cycleStartDay => _cycleStartDay;
  String get currencySymbol => _currencySymbol;

  List<IncomeModel> get incomes => List.unmodifiable(_incomes);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<GoalModel> get goals => List.unmodifiable(_goals);
  List<TemplateModel> get templates => List.unmodifiable(_templates);
  List<String> get recordedCycleMonths => List.unmodifiable(_recordedCycleMonths);

  double get lifetimeInflow => _lifetimeInflow;
  double get lifetimeBurned => _lifetimeBurned;
  double get lifetimeInvested => _lifetimeInvested;
  double get lifetimeSaved => (_lifetimeInflow - (_lifetimeBurned + _lifetimeInvested)).clamp(0.0, double.infinity);
  int get lifetimeMonthsCount => _lifetimeMonthsCount > 0 ? _lifetimeMonthsCount : 1;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.expense).toList();

  List<CategoryModel> get investmentCategories =>
      _categories.where((c) => c.type == CategoryType.investment).toList();

  // Financial Calculations
  double get totalInflow =>
      _incomes.fold(0.0, (sum, item) => sum + item.amount);

  double get totalBurned {
    double sum = 0.0;
    for (final cat in expenseCategories) {
      if (cat.id != null) {
        sum += getCategorySpent(cat.id!);
      }
    }
    return sum;
  }

  double get totalInvested {
    double sum = 0.0;
    for (final cat in investmentCategories) {
      if (cat.id != null) {
        sum += getCategorySpent(cat.id!);
      }
    }
    return sum;
  }

  double get totalAllocatedBudget =>
      _categories.fold(0.0, (sum, cat) => sum + cat.budgetLimit);

  double get unspentBalance =>
      totalInflow - (totalBurned + totalInvested);

  double get burnPercentage =>
      totalInflow > 0 ? ((totalBurned / totalInflow) * 100).clamp(0, 100) : 0.0;

  double get investPercentage =>
      totalInflow > 0 ? ((totalInvested / totalInflow) * 100).clamp(0, 100) : 0.0;

  double get unspentPercentage =>
      totalInflow > 0 ? (100.0 - (burnPercentage + investPercentage)).clamp(0, 100) : 0.0;

  double getCategorySpent(int categoryId) =>
      _categorySpentMap[categoryId] ?? 0.0;

  double getCategoryRemaining(CategoryModel category) {
    if (category.id == null) return category.budgetLimit;
    return category.budgetLimit - getCategorySpent(category.id!);
  }

  double getCategoryProgress(CategoryModel category) {
    if (category.budgetLimit <= 0) return 0.0;
    final spent = getCategorySpent(category.id ?? -1);
    return (spent / category.budgetLimit).clamp(0.0, 1.0);
  }

  CategoryModel? findCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Load / Refresh State
  Future<void> loadBudgetData([String? cycleMonth]) async {
    _isLoading = true;
    notifyListeners();

    final savedStartDay = await _repository.getSetting('cycle_start_day');
    _cycleStartDay = savedStartDay != null ? int.tryParse(savedStartDay) ?? 1 : 1;

    if (cycleMonth != null) {
      _currentCycleMonth = cycleMonth;
    }

    _currencySymbol = await _repository.getSetting('currency_symbol') ?? '₹';
    _categories = await _repository.getAllCategories();
    _incomes = await _repository.getIncomes(_currentCycleMonth);
    _transactions = await _repository.getTransactions(_currentCycleMonth);
    _goals = await _repository.getAllGoals();
    _templates = await _repository.getAllTemplates();
    _recordedCycleMonths = await _repository.getRecordedCycleMonths();
    _lifetimeInflow = await _repository.getLifetimeInflow();
    _lifetimeBurned = await _repository.getLifetimeBurned();
    _lifetimeInvested = await _repository.getLifetimeInvested();
    _lifetimeMonthsCount = await _repository.getLifetimeMonthsCount();

    _categorySpentMap.clear();
    for (final cat in _categories) {
      if (cat.id != null) {
        _categorySpentMap[cat.id!] =
            await _repository.getCategorySpent(cat.id!, _currentCycleMonth);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cycle Management
  Future<void> switchCycleMonth(String cycleMonth) async {
    await loadBudgetData(cycleMonth);
  }

  Future<void> setCycleStartDay(int day) async {
    _cycleStartDay = day;
    await _repository.setSetting('cycle_start_day', day.toString());
    final newCycle = DateHelpers.getCycleMonthForDate(DateTime.now(), _cycleStartDay);
    await loadBudgetData(newCycle);
  }

  // Action: Add Cash Inflow
  Future<void> addIncome({
    required String source,
    required double amount,
    int? createdAt,
  }) async {
    final income = IncomeModel(
      source: source,
      amount: amount,
      cycleMonth: _currentCycleMonth,
      createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.addIncome(income);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Record Transaction (Immediate deduction from category envelope)
  Future<void> recordTransaction({
    required int categoryId,
    required double amount,
    String? description,
    int? createdAt,
  }) async {
    final transaction = TransactionModel(
      categoryId: categoryId,
      amount: amount,
      description: description,
      cycleMonth: _currentCycleMonth,
      createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.addTransaction(transaction);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Delete Transaction
  Future<void> deleteTransaction(int transactionId) async {
    await _repository.deleteTransaction(transactionId);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Update Category Budget
  Future<void> updateCategoryBudget(int categoryId, double newBudgetLimit) async {
    final cat = findCategoryById(categoryId);
    if (cat != null) {
      final updated = cat.copyWith(budgetLimit: newBudgetLimit);
      await _repository.updateCategory(updated);
      await loadBudgetData(_currentCycleMonth);
    }
  }

  // Action: Create New Category
  Future<void> createCategory({
    required String name,
    required double budgetLimit,
    required CategoryType type,
    String? iconName,
  }) async {
    final category = CategoryModel(
      name: name,
      budgetLimit: budgetLimit,
      type: type,
      iconName: iconName,
      sortOrder: _categories.length + 1,
    );
    await _repository.addCategory(category);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Save toward Goal
  Future<void> addSavingsToGoal(int goalId, double amount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updated = goal.copyWith(currentSaved: goal.currentSaved + amount);
      await _repository.updateGoal(updated);

      // If goal is linked to an investment category, log a transaction for this cycle
      if (goal.categoryId != null) {
        await recordTransaction(
          categoryId: goal.categoryId!,
          amount: amount,
          description: 'Saved toward ${goal.title}',
        );
      } else {
        await loadBudgetData(_currentCycleMonth);
      }
    }
  }

  // Action: Create New Goal
  Future<void> createGoal({
    required String title,
    required double targetAmount,
    double monthlyBudgetAllocation = 0.0,
    int? categoryId,
  }) async {
    final goal = GoalModel(
      title: title,
      targetAmount: targetAmount,
      currentSaved: 0.0,
      monthlyBudgetAllocation: monthlyBudgetAllocation,
      categoryId: categoryId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repository.addGoal(goal);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Create New Template
  Future<void> createTemplate({
    required String title,
    required int categoryId,
    required double defaultAmount,
    String? defaultDescription,
    int? sortOrder,
  }) async {
    final template = TemplateModel(
      title: title,
      categoryId: categoryId,
      defaultAmount: defaultAmount,
      defaultDescription: defaultDescription,
      sortOrder: sortOrder ?? (_templates.length + 1),
    );
    await _repository.addTemplate(template);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Update Template
  Future<void> updateTemplate(TemplateModel template) async {
    await _repository.updateTemplate(template);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: Delete Template
  Future<void> deleteTemplate(int id) async {
    await _repository.deleteTemplate(id);
    await loadBudgetData(_currentCycleMonth);
  }

  // Action: 1-Tap Apply Template to current cycle
  Future<void> applyTemplate(TemplateModel template, [double? customAmount]) async {
    await recordTransaction(
      categoryId: template.categoryId,
      amount: customAmount ?? template.defaultAmount,
      description: (template.defaultDescription != null && template.defaultDescription!.trim().isNotEmpty)
          ? template.defaultDescription
          : template.title,
    );
  }
}
