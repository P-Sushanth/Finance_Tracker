import '../../core/database/database_helper.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/goal_model.dart';
import '../../shared/models/income_model.dart';
import '../../shared/models/template_model.dart';
import '../../shared/models/transaction_model.dart';

/// Repository for handling all budget, category, income, and transaction database queries
class BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper();

  // Incomes
  Future<int> addIncome(IncomeModel income) => _dbHelper.insertIncome(income);
  Future<List<IncomeModel>> getIncomes(String cycleMonth) => _dbHelper.getIncomesForMonth(cycleMonth);
  Future<double> getTotalIncome(String cycleMonth) => _dbHelper.getTotalIncomeForMonth(cycleMonth);

  // Categories
  Future<List<CategoryModel>> getAllCategories() => _dbHelper.getAllCategories();
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) => _dbHelper.getCategoriesByType(type);
  Future<int> addCategory(CategoryModel category) => _dbHelper.insertCategory(category);
  Future<int> updateCategory(CategoryModel category) => _dbHelper.updateCategory(category);
  Future<int> deleteCategory(int id) => _dbHelper.deleteCategory(id);

  // Transactions
  Future<int> addTransaction(TransactionModel transaction) => _dbHelper.insertTransaction(transaction);
  Future<List<TransactionModel>> getTransactions(String cycleMonth) => _dbHelper.getTransactionsForMonth(cycleMonth);
  Future<double> getCategorySpent(int categoryId, String cycleMonth) => _dbHelper.getCategorySpentForMonth(categoryId, cycleMonth);
  Future<int> deleteTransaction(int id) => _dbHelper.deleteTransaction(id);
  Future<List<String>> getRecordedCycleMonths() => _dbHelper.getRecordedCycleMonths();

  // Goals
  Future<List<GoalModel>> getAllGoals() => _dbHelper.getAllGoals();
  Future<int> addGoal(GoalModel goal) => _dbHelper.insertGoal(goal);
  Future<int> updateGoal(GoalModel goal) => _dbHelper.updateGoal(goal);
  Future<int> deleteGoal(int id) => _dbHelper.deleteGoal(id);

  // Templates
  Future<List<TemplateModel>> getAllTemplates() => _dbHelper.getAllTemplates();
  Future<int> addTemplate(TemplateModel template) => _dbHelper.insertTemplate(template);
  Future<int> updateTemplate(TemplateModel template) => _dbHelper.updateTemplate(template);
  Future<int> deleteTemplate(int id) => _dbHelper.deleteTemplate(id);

  // Lifetime Analytics
  Future<double> getLifetimeInflow() => _dbHelper.getLifetimeInflow();
  Future<double> getLifetimeBurned() => _dbHelper.getLifetimeBurned();
  Future<double> getLifetimeInvested() => _dbHelper.getLifetimeInvested();
  Future<int> getLifetimeMonthsCount() => _dbHelper.getLifetimeMonthsCount();

  // Backup & Restore
  Future<Map<String, dynamic>> exportAllData() => _dbHelper.exportAllData();
  Future<String> exportTransactionsCsv() => _dbHelper.exportTransactionsCsv();
  Future<bool> restoreAllData(Map<String, dynamic> backup) => _dbHelper.restoreAllData(backup);

  // App Settings
  Future<String?> getSetting(String key) => _dbHelper.getSetting(key);
  Future<void> setSetting(String key, String value) => _dbHelper.setSetting(key, value);
}

