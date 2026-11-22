import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/models/goal_model.dart';
import '../budget/budget_controller.dart';

class GoalsScreen extends StatelessWidget {
  final BudgetController controller;

  const GoalsScreen({
    super.key,
    required this.controller,
  });

  void _showNewGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final monthlyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Financial Goal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Goal Title (e.g. Emergency Corpus, Vacation)',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Target Amount (${controller.currencySymbol})',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    prefixText: '${controller.currencySymbol} ',
                    prefixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthlyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Monthly Contribution Allocation (${controller.currencySymbol})',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    prefixText: '${controller.currencySymbol} ',
                    prefixStyle: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.sage : AppColors.charcoal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                        final monthly = double.tryParse(monthlyController.text.trim()) ?? 0.0;

                        if (title.isNotEmpty && target > 0) {
                          await controller.createGoal(
                            title: title,
                            targetAmount: target,
                            monthlyBudgetAllocation: monthly,
                          );
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('Create Goal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSavingsDialog(BuildContext context, GoalModel goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deposit Toward ${goal.title}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount to Save (${controller.currencySymbol})',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    prefixText: '${controller.currencySymbol} ',
                    prefixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sage,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                        if (amt > 0 && goal.id != null) {
                          await controller.addSavingsToGoal(goal.id!, amt);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('Confirm Deposit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAccumulated = controller.goals.fold(0.0, (sum, g) => sum + g.currentSaved);
    final totalTarget = controller.goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final overallProgress = totalTarget > 0 ? (totalAccumulated / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Targets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'New Goal',
            onPressed: () => _showNewGoalDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Overall Corpus Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL SAVED FOR GOALS', style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(totalAccumulated, symbol: controller.currencySymbol),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('OVERALL TARGET', style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(totalTarget, symbol: controller.currencySymbol),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 8,
                            width: double.infinity,
                            color: isDark ? const Color(0xFF2E3236) : const Color(0xFFF0EFEA),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: overallProgress,
                              child: Container(color: AppColors.sage),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(overallProgress * 100).toStringAsFixed(1)}% achieved',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Active Targets Header
                Text('ACTIVE HORIZONS', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10),

                if (controller.goals.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.track_changes_outlined,
                              size: 36,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 8),
                            Text('No goals added yet', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Create targets to track long-term savings horizons (e.g. Emergency Fund, Travel)',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF383E46) : AppColors.charcoal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _showNewGoalDialog(context),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Goal'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.goals.map((goal) {
                    final progress = goal.targetAmount > 0
                        ? (goal.currentSaved / goal.targetAmount).clamp(0.0, 1.0)
                        : 0.0;
                    final remaining = goal.targetAmount - goal.currentSaved;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E3326) : AppColors.sageLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.track_changes_rounded,
                                          size: 20,
                                          color: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
                                          if (goal.monthlyBudgetAllocation > 0)
                                            Text(
                                              'Monthly Allocation: ${CurrencyFormatter.format(goal.monthlyBudgetAllocation, symbol: controller.currencySymbol)}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? const Color(0xFF1E3326) : AppColors.sageLight,
                                      foregroundColor: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _showAddSavingsDialog(context, goal),
                                    child: const Text('+ Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(goal.currentSaved, symbol: controller.currencySymbol),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                                    ),
                                  ),
                                  Text(
                                    'Target ${CurrencyFormatter.format(goal.targetAmount, symbol: controller.currencySymbol)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 6,
                                  width: double.infinity,
                                  color: isDark ? const Color(0xFF2E3236) : const Color(0xFFF0EFEA),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress,
                                    child: Container(color: AppColors.sage),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% saved',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                                  ),
                                  Text(
                                    remaining > 0
                                        ? '${CurrencyFormatter.format(remaining, symbol: controller.currencySymbol)} remaining'
                                        : 'Goal Achieved',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: remaining <= 0
                                          ? (isDark ? const Color(0xFF68B29A) : AppColors.sage)
                                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 70), // Bottom padding for dock
              ],
            ),
          ),
        ),
      ),
    );
  }
}

