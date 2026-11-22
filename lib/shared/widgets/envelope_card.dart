import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/models/category_model.dart';

class EnvelopeCard extends StatelessWidget {
  final CategoryModel category;
  final double spent;
  final String currencySymbol;
  final VoidCallback? onTap;

  const EnvelopeCard({
    super.key,
    required this.category,
    required this.spent,
    this.currencySymbol = '₹',
    this.onTap,
  });

  IconData _getCategoryIcon(String? iconName, CategoryType type) {
    if (type == CategoryType.investment) {
      if (iconName == 'shield') return Icons.shield_outlined;
      return Icons.trending_up_rounded;
    }
    switch (iconName) {
      case 'utensils':
        return Icons.restaurant_outlined;
      case 'navigation':
        return Icons.navigation_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInvestment = category.type == CategoryType.investment;
    final remaining = category.budgetLimit - spent;
    final isOverbudget = !isInvestment && remaining < 0;

    final progress = category.budgetLimit > 0
        ? (spent / category.budgetLimit).clamp(0.0, 1.0)
        : (spent > 0 ? 1.0 : 0.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C3034)
                              : (isInvestment
                                  ? AppColors.sageLight
                                  : const Color(0xFFEBE8E0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category.iconName, category.type),
                          size: 19,
                          color: isInvestment
                              ? AppColors.sage
                              : (isDark ? Colors.white : AppColors.charcoal),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isInvestment
                                ? 'Target ${CurrencyFormatter.format(category.budgetLimit, symbol: currencySymbol)}'
                                : 'Budget ${CurrencyFormatter.format(category.budgetLimit, symbol: currencySymbol)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isInvestment
                            ? CurrencyFormatter.format(spent, symbol: currencySymbol)
                            : '${CurrencyFormatter.format(remaining, symbol: currencySymbol)} left',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isInvestment
                              ? AppColors.sage
                              : (isOverbudget
                                  ? AppColors.terracotta
                                  : (isDark ? Colors.white : AppColors.charcoal)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isInvestment
                            ? (category.budgetLimit > 0 && spent >= category.budgetLimit
                                ? 'Target Met'
                                : '${CurrencyFormatter.format(spent, symbol: currencySymbol)} saved')
                            : '${CurrencyFormatter.format(spent, symbol: currencySymbol)} spent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOverbudget
                                  ? AppColors.terracotta
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar with clear track background
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF2E3236) : const Color(0xFFE2E0D8),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      color: isInvestment
                          ? AppColors.sage
                          : (isOverbudget
                              ? AppColors.terracotta
                              : (isDark ? AppColors.sageMuted : AppColors.charcoal)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

