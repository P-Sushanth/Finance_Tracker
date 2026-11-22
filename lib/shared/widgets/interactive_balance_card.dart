import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class InteractiveBalanceCard extends StatefulWidget {
  final double totalInflow;
  final double totalBurned;
  final double totalInvested;
  final double unspent;
  final String currencySymbol;

  const InteractiveBalanceCard({
    super.key,
    required this.totalInflow,
    required this.totalBurned,
    required this.totalInvested,
    required this.unspent,
    this.currencySymbol = '₹',
  });

  @override
  State<InteractiveBalanceCard> createState() => _InteractiveBalanceCardState();
}

class _InteractiveBalanceCardState extends State<InteractiveBalanceCard> {
  String? _activeTooltipText;
  Color? _activeTooltipColor;

  void _showTooltip(String text, Color color) {
    setState(() {
      _activeTooltipText = text;
      _activeTooltipColor = color;
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _activeTooltipText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final burnPct = widget.totalInflow > 0
        ? (widget.totalBurned / widget.totalInflow).clamp(0.0, 1.0)
        : 0.0;
    final investPct = widget.totalInflow > 0
        ? (widget.totalInvested / widget.totalInflow).clamp(0.0, 1.0)
        : 0.0;
    final unspentPct = widget.totalInflow > 0
        ? (widget.unspent / widget.totalInflow).clamp(0.0, 1.0)
        : 0.0;

    return Card(
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
                    Text(
                      'TOTAL INFLOW',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(widget.totalInflow, symbol: widget.currencySymbol),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'UNSPENT',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(widget.unspent, symbol: widget.currencySymbol),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: widget.unspent >= 0 ? AppColors.sage : AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Interactive Proportion Bar
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 12,
                  width: double.infinity,
                  color: const Color(0xFFF0EFEA),
                  child: Row(
                    children: [
                      if (burnPct > 0)
                        Flexible(
                          flex: (burnPct * 1000).toInt(),
                          child: GestureDetector(
                            onTap: () => _showTooltip(
                              'Outflow: ${CurrencyFormatter.format(widget.totalBurned, symbol: widget.currencySymbol)} • ${(burnPct * 100).toStringAsFixed(0)}%',
                              AppColors.terracotta,
                            ),
                            child: Container(color: AppColors.terracotta),
                          ),
                        ),
                      if (investPct > 0)
                        Flexible(
                          flex: (investPct * 1000).toInt(),
                          child: GestureDetector(
                            onTap: () => _showTooltip(
                              'Invested: ${CurrencyFormatter.format(widget.totalInvested, symbol: widget.currencySymbol)} • ${(investPct * 100).toStringAsFixed(0)}%',
                              AppColors.sage,
                            ),
                            child: Container(color: AppColors.sage),
                          ),
                        ),
                      if (unspentPct > 0)
                        Flexible(
                          flex: (unspentPct * 1000).toInt(),
                          child: GestureDetector(
                            onTap: () => _showTooltip(
                              'Unspent: ${CurrencyFormatter.format(widget.unspent, symbol: widget.currencySymbol)} • ${(unspentPct * 100).toStringAsFixed(0)}%',
                              AppColors.charcoal,
                            ),
                            child: Container(color: AppColors.neutralSlate),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Tooltip Notification if a segment was tapped
            if (_activeTooltipText != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _activeTooltipColor ?? AppColors.charcoal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _activeTooltipText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

