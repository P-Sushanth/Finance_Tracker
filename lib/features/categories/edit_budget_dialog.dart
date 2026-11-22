import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/category_model.dart';
import '../budget/budget_controller.dart';

class EditBudgetDialog extends StatefulWidget {
  final BudgetController controller;
  final CategoryModel? categoryToEdit;

  const EditBudgetDialog({
    super.key,
    required this.controller,
    this.categoryToEdit,
  });

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late CategoryType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
    _budgetController = TextEditingController(
      text: widget.categoryToEdit != null && widget.categoryToEdit!.budgetLimit > 0
          ? widget.categoryToEdit!.budgetLimit.toStringAsFixed(0)
          : '',
    );
    _selectedType = widget.categoryToEdit?.type ?? CategoryType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

    if (name.isEmpty) return;

    if (widget.categoryToEdit != null) {
      await widget.controller.updateCategoryBudget(widget.categoryToEdit!.id!, budget);
    } else {
      await widget.controller.createCategory(
        name: name,
        budgetLimit: budget,
        type: _selectedType,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;

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
              isEditing ? 'Edit Category Budget' : 'New Envelope Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Category Name Input
            TextField(
              controller: _nameController,
              enabled: !isEditing,
              decoration: InputDecoration(
                labelText: 'Category Name',
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

            // Budget Limit Input
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: _selectedType == CategoryType.investment ? 'Target Goal (₹)' : 'Monthly Budget (₹)',
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
            const SizedBox(height: 12),

            // Type selector (only when creating new category)
            if (!isEditing) ...[
              const Text(
                'TYPE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Expense')),
                      selected: _selectedType == CategoryType.expense,
                      selectedColor: AppColors.terracottaLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedType == CategoryType.expense ? AppColors.terracotta : AppColors.textSecondaryLight,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = CategoryType.expense);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Growth')),
                      selected: _selectedType == CategoryType.investment,
                      selectedColor: AppColors.sageLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedType == CategoryType.investment ? AppColors.sage : AppColors.textSecondaryLight,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = CategoryType.investment);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 8),
            ],

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
                  child: const Text('Save Budget'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

