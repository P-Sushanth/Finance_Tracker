import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../budget/budget_controller.dart';

class AddIncomeDialog extends StatefulWidget {
  final BudgetController controller;

  const AddIncomeDialog({
    super.key,
    required this.controller,
  });

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final TextEditingController _sourceController = TextEditingController(text: 'Monthly Salary');
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final source = _sourceController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (source.isEmpty || amount <= 0) return;

    await widget.controller.addIncome(
      source: source,
      amount: amount,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Cash Inflow',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Inflow Source
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: 'Source (e.g. Salary, Stipend, Freelance)',
                labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: const Color(0xFFF5F4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Inflow Amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                prefixText: '${widget.controller.currencySymbol} ',
                filled: true,
                fillColor: const Color(0xFFF5F4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleSave,
                  child: const Text('Record Inflow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

