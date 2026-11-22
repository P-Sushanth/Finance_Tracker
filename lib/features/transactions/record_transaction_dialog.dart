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
              'Record Transaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${widget.controller.currencySymbol} ',
                filled: true,
                fillColor: const Color(0xFFF5F4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Selector Chips
            const Text(
              'SELECT CATEGORY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
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
                      selectedColor: isInvestment ? AppColors.sageLight : AppColors.charcoal,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isInvestment ? AppColors.sage : Colors.white)
                            : AppColors.textPrimaryLight,
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
              decoration: InputDecoration(
                labelText: 'Reason / Description (optional)',
                labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: const Color(0xFFF5F4F0),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
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

