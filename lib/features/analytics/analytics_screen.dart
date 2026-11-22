import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../budget/budget_controller.dart';
import 'donut_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  final BudgetController controller;

  const AnalyticsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final PageController _pageController;
  int _currentCarouselPage = 0;
  String _filterType = 'all'; // 'all', 'expenses', 'investments'

  static const List<Color> _burnColors = [
    Color(0xFF2A363B),
    Color(0xFF8D5B4C),
    Color(0xFFBA4E3B),
    Color(0xFFD9822B),
    Color(0xFF786C5E),
    Color(0xFFA67C52),
  ];

  static const List<Color> _growthColors = [
    Color(0xFF4D7266),
    Color(0xFF8FA89B),
    Color(0xFF385E52),
    Color(0xFFA7C1B5),
    Color(0xFF2E4D43),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions() {
    final txs = widget.controller.transactions;
    if (_filterType == 'expenses') {
      return txs.where((t) {
        final cat = widget.controller.findCategoryById(t.categoryId);
        return cat?.type == CategoryType.expense;
      }).toList();
    } else if (_filterType == 'investments') {
      return txs.where((t) {
        final cat = widget.controller.findCategoryById(t.categoryId);
        return cat?.type == CategoryType.investment;
      }).toList();
    }
    return txs;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // 1. Net Flow Split Slices
    final netFlowSlices = <DonutSlice>[];
    if (controller.totalBurned > 0) {
      netFlowSlices.add(DonutSlice(
        label: 'Burned',
        amount: controller.totalBurned,
        color: AppColors.terracotta,
        percentage: controller.burnPercentage,
      ));
    }
    if (controller.totalInvested > 0) {
      netFlowSlices.add(DonutSlice(
        label: 'Invested',
        amount: controller.totalInvested,
        color: AppColors.sage,
        percentage: controller.investPercentage,
      ));
    }
    if (controller.unspentBalance > 0) {
      netFlowSlices.add(DonutSlice(
        label: 'Saved',
        amount: controller.unspentBalance,
        color: const Color(0xFF94A3B8),
        percentage: controller.unspentPercentage,
      ));
    }

    // 2. Burn Distribution Slices (Expense categories)
    final burnSlices = <DonutSlice>[];
    int burnColorIdx = 0;
    for (final cat in controller.expenseCategories) {
      if (cat.id != null) {
        final spent = controller.getCategorySpent(cat.id!);
        if (spent > 0) {
          final pct = controller.totalBurned > 0 ? (spent / controller.totalBurned) * 100 : 0.0;
          burnSlices.add(DonutSlice(
            label: cat.name,
            amount: spent,
            color: _burnColors[burnColorIdx % _burnColors.length],
            percentage: pct,
          ));
          burnColorIdx++;
        }
      }
    }

    // 3. Growth Allocation Slices (Investment categories)
    final growthSlices = <DonutSlice>[];
    int growthColorIdx = 0;
    for (final cat in controller.investmentCategories) {
      if (cat.id != null) {
        final spent = controller.getCategorySpent(cat.id!);
        if (spent > 0) {
          final pct = controller.totalInvested > 0 ? (spent / controller.totalInvested) * 100 : 0.0;
          growthSlices.add(DonutSlice(
            label: cat.name,
            amount: spent,
            color: _growthColors[growthColorIdx % _growthColors.length],
            percentage: pct,
          ));
          growthColorIdx++;
        }
      }
    }

    final filteredTransactions = _getFilteredTransactions();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFOGRAPHICS & METRICS',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Financial Analytics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE9E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateHelpers.formatMonthTitle(controller.currentCycleMonth),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Swipable 3-Page Donut Carousel Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE5E2D9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Carousel Header with Title and 3 Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCarouselTitle(_currentCarouselPage),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        // 3 Pagination Dots
                        Row(
                          children: List.generate(3, (idx) {
                            final isActive = _currentCarouselPage == idx;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: isActive ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.charcoal : const Color(0xFFD5D3CC),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Swipable Carousel View
                    SizedBox(
                      height: 290,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) => setState(() => _currentCarouselPage = page),
                        children: [
                          // Page 0: Net Flow Split
                          CustomDonutChart(
                            slices: netFlowSlices,
                            defaultTitle: 'Net Inflow',
                            totalAmount: controller.totalInflow,
                            currencySymbol: controller.currencySymbol,
                            defaultSubtitle: '100% Inflow',
                            emptyMessage: 'No income logged for this cycle.',
                          ),

                          // Page 1: Burn Distribution
                          CustomDonutChart(
                            slices: burnSlices,
                            defaultTitle: 'Total Burn',
                            totalAmount: controller.totalBurned,
                            currencySymbol: controller.currencySymbol,
                            defaultSubtitle: '100% Outflow',
                            emptyMessage: 'No expenses recorded in this cycle.',
                          ),

                          // Page 2: Growth Allocation
                          CustomDonutChart(
                            slices: growthSlices,
                            defaultTitle: 'Total Growth',
                            totalAmount: controller.totalInvested,
                            currencySymbol: controller.currencySymbol,
                            defaultSubtitle: '100% Growth',
                            emptyMessage: 'No investments or savings recorded in this cycle.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lifetime Cumulative Metrics Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFFE5E2D9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LIFETIME',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${controller.lifetimeMonthsCount} ${controller.lifetimeMonthsCount == 1 ? "Month" : "Months"}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Invested
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.sageLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'INVESTED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: AppColors.sage,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatCompact(controller.lifetimeInvested, symbol: controller.currencySymbol),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.sage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Saved
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F4F0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'SAVED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatCompact(controller.lifetimeSaved, symbol: controller.currencySymbol),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Burned
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.terracottaLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'BURNED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatCompact(controller.lifetimeBurned, symbol: controller.currencySymbol),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filterable Activity Feed Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACTIVITY FEED',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textSecondaryLight),
                ),
                // Filter Segmented Chips
                Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filterType == 'all',
                      onTap: () => setState(() => _filterType = 'all'),
                    ),
                    const SizedBox(width: 4),
                    _FilterChip(
                      label: 'Expenses',
                      isSelected: _filterType == 'expenses',
                      onTap: () => setState(() => _filterType = 'expenses'),
                    ),
                    const SizedBox(width: 4),
                    _FilterChip(
                      label: 'Investments',
                      isSelected: _filterType == 'investments',
                      onTap: () => setState(() => _filterType = 'investments'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Activity List
            if (filteredTransactions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No transactions match this filter for ${DateHelpers.formatMonthTitle(controller.currentCycleMonth)}.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              ...filteredTransactions.map((tx) {
                final category = controller.findCategoryById(tx.categoryId);
                final isInvestment = category?.type == CategoryType.investment;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: ValueKey('analytics_${tx.id ?? tx.createdAt}'),
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
                      if (tx.id != null) controller.deleteTransaction(tx.id!);
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
    );
  }

  String _getCarouselTitle(int page) {
    switch (page) {
      case 0:
        return 'Net Flow Split';
      case 1:
        return 'Burn Distribution';
      case 2:
        return 'Growth Allocation';
      default:
        return 'Analytics';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.charcoal
              : (isDark ? const Color(0xFF2B2F33) : const Color(0xFFE8E5DD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}

