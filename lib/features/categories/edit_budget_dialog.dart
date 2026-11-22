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
      final updated = widget.categoryToEdit!.copyWith(
        name: name,
        budgetLimit: budget,
        type: _selectedType,
      );
      await widget.controller.updateCategory(updated);
    } else {
      await widget.controller.createCategory(
        name: name,
        budgetLimit: budget,
        type: _selectedType,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    if (widget.categoryToEdit?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Envelope', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(
          'Are you sure you want to delete "${widget.categoryToEdit!.name}"? Past transactions in this category will be preserved in historical records.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.controller.deleteCategory(widget.categoryToEdit!.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF2C3034) : const Color(0xFFF3F1EC);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Envelope' : 'New Envelope Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.terracotta, size: 22),
                    tooltip: 'Delete Envelope',
                    onPressed: _handleDelete,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Name Input
            TextField(
              controller: _nameController,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor: inputFill,
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: _selectedType == CategoryType.investment ? 'Target Goal (₹)' : 'Monthly Budget (₹)',
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                prefixText: '${widget.controller.currencySymbol} ',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                ),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Type selector
            Text(
              'CLASSIFICATION TYPE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedType = CategoryType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == CategoryType.expense
                            ? AppColors.terracotta
                            : inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Outflow (Expense)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedType == CategoryType.expense
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedType = CategoryType.investment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == CategoryType.investment
                            ? AppColors.sage
                            : inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Growth (Asset)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedType == CategoryType.investment
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleSave,
                  child: Text(isEditing ? 'Update Envelope' : 'Save Envelope', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
