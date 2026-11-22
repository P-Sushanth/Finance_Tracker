import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../shared/models/category_model.dart';
import '../../shared/widgets/envelope_card.dart';
import '../../shared/widgets/interactive_balance_card.dart';
import '../budget/budget_controller.dart';
import '../categories/edit_budget_dialog.dart';
import '../income/add_income_dialog.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final BudgetController controller;

  const HomeScreen({
    super.key,
    required this.controller,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _envelopeTab = 'expenses'; // 'expenses' or 'growth'

  void _openEditBudgetModal([CategoryModel? category]) {
    showDialog(
      context: context,
      builder: (_) => EditBudgetDialog(
        controller: widget.controller,
        categoryToEdit: category,
      ),
    );
  }

  void _openAddIncomeModal() {
    showDialog(
      context: context,
      builder: (_) => AddIncomeDialog(controller: widget.controller),
    );
  }

  void _openQuickAddModal([int? preselectedCategoryId]) {
    QuickAddSheet.show(context, widget.controller, preselectedCategoryId);
  }

  void _openCycleSelectorSheet() {
    final controller = widget.controller;
    final currentActualCycle = DateHelpers.getCycleMonthForDate(DateTime.now(), controller.cycleStartDay);
    
    // Combine recorded months and recent months into a unique list
    final monthSet = <String>{};
    monthSet.add(currentActualCycle);
    monthSet.addAll(controller.recordedCycleMonths);
    monthSet.addAll(DateHelpers.getRecentCycleMonths(6));
    final sortedMonths = monthSet.toList()..sort((a, b) => b.compareTo(a));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF383D43) : const Color(0xFFD5D3CC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Monthly Cycle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                    tooltip: 'Cycle Settings',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openCycleSettingsDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Cycle start day: ${controller.cycleStartDay}${_getDaySuffix(controller.cycleStartDay)} of each month',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),
              ...sortedMonths.map((m) {
                final isSelected = m == controller.currentCycleMonth;
                final isCurrent = m == currentActualCycle;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      controller.switchCycleMonth(m);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF383E46) : AppColors.charcoal)
                            : (isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0)),
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: isDark ? const Color(0xFF383D43) : const Color(0xFFE5E2D9),
                              ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCurrent ? Icons.today_rounded : Icons.calendar_month_outlined,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateHelpers.formatMonthTitle(m),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                ),
                              ),
                            ],
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.sage
                                    : (isDark ? const Color(0xFF1E3326) : AppColors.sageLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF68B29A) : AppColors.sage),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openCycleSettingsDialog() {
    final controller = widget.controller;
    int selectedDay = controller.cycleStartDay;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Cycle Start Day',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set the calendar day your monthly budget cycle resets (e.g. 1st or salary day like 25th).',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF383D43) : const Color(0xFFE5E2D9),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedDay,
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      items: [1, 5, 10, 15, 20, 25, 28].map((day) {
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(
                            '$day${_getDaySuffix(day)} of the month',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDay = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.sage : AppColors.charcoal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await controller.setCycleStartDay(selectedDay);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final currentActualCycle = DateHelpers.getCycleMonthForDate(DateTime.now(), controller.cycleStartDay);
    final isViewingPastCycle = controller.currentCycleMonth != currentActualCycle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Month Cycle Header (Clickable to switch cycles)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _openCycleSelectorSheet,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MONTHLY CYCLE',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateHelpers.formatMonthTitle(controller.currentCycleMonth),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262A2E) : const Color(0xFFEBE9E1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateHelpers.getCycleProgressString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                            color: isDark ? Colors.white : AppColors.charcoal,
                          ),
                          tooltip: 'Quick-Add Outflow',
                          onPressed: () => _openQuickAddModal(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_downward_rounded,
                            size: 20,
                            color: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                          ),
                          tooltip: 'Add Inflow',
                          onPressed: _openAddIncomeModal,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          ),
                          tooltip: 'Settings & Backup',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SettingsScreen(controller: widget.controller),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // Past Cycle Archive Indicator Banner (if viewing previous month)
                if (isViewingPastCycle) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262A2E) : const Color(0xFFEBE9E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.cardBorderDark : const Color(0xFFD5D3CC),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Viewing archive for ${DateHelpers.formatMonthTitle(controller.currentCycleMonth)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.switchCycleMonth(currentActualCycle),
                          child: Text(
                            'Back to Current',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF68B29A) : AppColors.sage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            const SizedBox(height: 16),

            // Interactive Balance Summary Card
            InteractiveBalanceCard(
              totalInflow: controller.totalInflow,
              totalBurned: controller.totalBurned,
              totalInvested: controller.totalInvested,
              unspent: controller.unspentBalance,
              currencySymbol: controller.currencySymbol,
            ),
            const SizedBox(height: 20),

            // 2-Page Segmented Tab Header (Clean, high contrast)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF262A2E)
                        : const Color(0xFFE8E5DD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _envelopeTab = 'expenses'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _envelopeTab == 'expenses'
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _envelopeTab == 'expenses'
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                                : null,
                          ),
                          child: Text(
                            'Expenses',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _envelopeTab == 'expenses'
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight)
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _envelopeTab = 'growth'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _envelopeTab == 'growth'
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _envelopeTab == 'growth'
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                                : null,
                          ),
                          child: Text(
                            'Growth',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _envelopeTab == 'growth'
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight)
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF262A2E)
                        : const Color(0xFFEAE7DF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openEditBudgetModal(),
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.sage),
                  label: Text(
                    'New Envelope',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Envelopes List
            if (_envelopeTab == 'expenses') ...[
              if (controller.expenseCategories.isEmpty)
                _EmptyState(
                  text: 'No expense envelopes yet. Create envelopes to set monthly spending limits.',
                  actionLabel: 'Create Expense Envelope',
                  onAction: () => _openEditBudgetModal(),
                )
              else
                ...controller.expenseCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EnvelopeCard(
                      category: cat,
                      spent: controller.getCategorySpent(cat.id ?? -1),
                      currencySymbol: controller.currencySymbol,
                      onTap: () => _openEditBudgetModal(cat),
                    ),
                  );
                }),
            ] else ...[
              if (controller.investmentCategories.isEmpty)
                _EmptyState(
                  text: 'No growth envelopes yet. Create envelopes to track investments, SIPs, and savings.',
                  actionLabel: 'Create Growth Envelope',
                  onAction: () => _openEditBudgetModal(),
                )
              else
                ...controller.investmentCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EnvelopeCard(
                      category: cat,
                      spent: controller.getCategorySpent(cat.id ?? -1),
                      currencySymbol: controller.currencySymbol,
                      onTap: () => _openEditBudgetModal(cat),
                    ),
                  );
                }),
            ],
            const SizedBox(height: 20),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT TRANSACTIONS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  'All ${controller.transactions.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (controller.transactions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No transactions logged in this cycle yet.\nTap "+" below to log a deduction.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              ...controller.transactions.take(8).map((tx) {
                final category = controller.findCategoryById(tx.categoryId);
                final isInvestment = category?.type == CategoryType.investment;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: ValueKey(tx.id ?? tx.createdAt),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: AppColors.terracottaLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.terracotta, size: 20),
                    ),
                    onDismissed: (_) {
                      if (tx.id != null) {
                        controller.deleteTransaction(tx.id!);
                      }
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isInvestment ? AppColors.sageLight : const Color(0xFFF0EFEA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isInvestment ? Icons.trending_up : Icons.arrow_outward_rounded,
                                size: 16,
                                color: isInvestment ? AppColors.sage : AppColors.terracotta,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description ?? category?.name ?? 'Transaction',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    '${category?.name ?? ""} • ${DateHelpers.formatTransactionTime(tx.createdAt)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isInvestment
                                  ? CurrencyFormatter.format(tx.amount, symbol: controller.currencySymbol)
                                  : '-${CurrencyFormatter.format(tx.amount, symbol: controller.currencySymbol)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isInvestment ? AppColors.sage : AppColors.terracotta,
                              ),
                            ),
                          ],
                        ),
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

class _EmptyState extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.textSecondaryLight),
            const SizedBox(height: 10),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
