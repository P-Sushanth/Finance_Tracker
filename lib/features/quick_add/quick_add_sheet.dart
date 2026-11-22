import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/category_model.dart';
import '../budget/budget_controller.dart';

enum QuickAddType { outflow, inflow }

class QuickAddSheet extends StatefulWidget {
  final BudgetController controller;
  final int? preselectedCategoryId;

  const QuickAddSheet({
    super.key,
    required this.controller,
    this.preselectedCategoryId,
  });

  static Future<void> show(BuildContext context, BudgetController controller, [int? categoryId]) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(
        controller: controller,
        preselectedCategoryId: categoryId,
      ),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  QuickAddType _currentType = QuickAddType.outflow;
  String _amountStr = '0';
  late final TextEditingController _descriptionController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    if (widget.controller.categories.isNotEmpty) {
      _selectedCategoryId = widget.preselectedCategoryId ?? widget.controller.categories.first.id;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'del') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else if (_amountStr.length < 9) {
          _amountStr += key;
        }
      }
    });
  }

  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) return;

    final note = _descriptionController.text.trim();

    if (_currentType == QuickAddType.outflow) {
      if (_selectedCategoryId == null) return;
      await widget.controller.recordTransaction(
        categoryId: _selectedCategoryId!,
        amount: amount,
        description: note.isNotEmpty ? note : null,
      );
    } else {
      await widget.controller.addIncome(
        source: note.isNotEmpty ? note : 'Cash Inflow',
        amount: amount,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isOutflow = _currentType == QuickAddType.outflow;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5D3CC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header with Inflow / Outflow Toggle and Cancel Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE9E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentType = QuickAddType.outflow),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOutflow ? AppColors.terracotta : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Outflow',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOutflow ? Colors.white : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _currentType = QuickAddType.inflow),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: !isOutflow ? AppColors.sage : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Inflow',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !isOutflow ? Colors.white : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondaryLight),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Numeric Amount Display Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                '${controller.currencySymbol} $_amountStr',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips (Only shown in Outflow mode, completely removed for Inflow)
          if (isOutflow) ...[
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: controller.categories.map((cat) {
                  final isSelected = cat.id == _selectedCategoryId;
                  final isInvestment = cat.type == CategoryType.investment;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: isInvestment ? AppColors.sage : AppColors.charcoal,
                      backgroundColor: const Color(0xFFF5F4F0),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
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
            const SizedBox(height: 10),
          ],

          // Reason / Description TextField
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: isOutflow
                  ? 'Description / Reason'
                  : 'Source Note (e.g. Salary, Stipend)',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              filled: true,
              fillColor: const Color(0xFFF5F4F0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Custom Keypad Grid
          Column(
            children: [
              _buildKeypadRow(['1', '2', '3']),
              const SizedBox(height: 8),
              _buildKeypadRow(['4', '5', '6']),
              const SizedBox(height: 8),
              _buildKeypadRow(['7', '8', '9']),
              const SizedBox(height: 8),
              _buildKeypadRow(['.', '0', 'del']),
            ],
          ),
          const SizedBox(height: 14),

          // Confirm / Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutflow ? AppColors.terracotta : AppColors.sage,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleSubmit,
            child: Text(
              isOutflow ? 'Record Outflow' : 'Record Inflow',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onKeyPress(key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: key == 'del' ? const Color(0xFFEBE9E1) : const Color(0xFFF5F4F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: key == 'del'
                      ? const Icon(Icons.backspace_outlined, size: 18, color: AppColors.textPrimaryLight)
                      : Text(
                          key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

