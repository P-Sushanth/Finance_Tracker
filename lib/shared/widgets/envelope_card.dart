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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isInvestment
                              ? AppColors.sageLight
                              : const Color(0xFFF0EFEA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category.iconName, category.type),
                          size: 18,
                          color: isInvestment ? AppColors.sage : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            isInvestment
                                ? 'Target ${CurrencyFormatter.format(category.budgetLimit, symbol: currencySymbol)}'
                                : 'Budget ${CurrencyFormatter.format(category.budgetLimit, symbol: currencySymbol)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
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
                              : (isOverbudget ? AppColors.terracotta : AppColors.charcoal),
                        ),
                      ),
                      Text(
                        isInvestment
                            ? (category.budgetLimit > 0 && spent >= category.budgetLimit
                                ? 'Target Met'
                                : '${CurrencyFormatter.format(spent, symbol: currencySymbol)} saved')
                            : '${CurrencyFormatter.format(spent, symbol: currencySymbol)} spent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              color: isOverbudget ? AppColors.terracotta : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: const Color(0xFFF0EFEA),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      color: isInvestment
                          ? AppColors.sage
                          : (isOverbudget ? AppColors.terracotta : AppColors.charcoal),
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

