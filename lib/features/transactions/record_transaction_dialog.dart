import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/category_model.dart';
import '../budget/budget_controller.dart';

class RecordTransactionDialog extends StatefulWidget {
  final BudgetController controller;
  final int? preselectedCategoryId;

  const RecordTransactionDialog({
    super.key,
    required this.controller,
    this.preselectedCategoryId,
  });

  @override
  State<RecordTransactionDialog> createState() => _RecordTransactionDialogState();
}

class _RecordTransactionDialogState extends State<RecordTransactionDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.preselectedCategoryId ??
        (widget.controller.categories.isNotEmpty ? widget.controller.categories.first.id : null);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final desc = _descController.text.trim();

    if (_selectedCategoryId == null || amount <= 0) return;

    await widget.controller.recordTransaction(
      categoryId: _selectedCategoryId!,
      amount: amount,
      description: desc.isNotEmpty ? desc : null,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'Record Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                prefixText: '${widget.controller.currencySymbol} ',
                prefixStyle: TextStyle(
                  fontSize: 22,
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

            // Category Selector Chips
            Text(
              'SELECT CATEGORY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.controller.categories.map((cat) {
                  final isSelected = cat.id == _selectedCategoryId;
                  final isInvestment = cat.type == CategoryType.investment;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: isInvestment
                          ? (isDark ? const Color(0xFF1E3326) : AppColors.sageLight)
                          : (isDark ? const Color(0xFF383E46) : AppColors.charcoal),
                      backgroundColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF0EFEA),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isInvestment
                                ? (isDark ? const Color(0xFF68B29A) : AppColors.sage)
                                : Colors.white)
                            : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                      ),
                      onSelected: (val) {
                        if (val && cat.id != null) {
                          setState(() => _selectedCategoryId = cat.id!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Description / Reason
            TextField(
              controller: _descController,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Reason / Description (optional)',
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
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: _handleSave,
                  child: const Text('Deduct From Budget'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

