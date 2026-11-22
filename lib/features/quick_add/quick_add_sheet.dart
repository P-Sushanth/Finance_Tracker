import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/models/category_model.dart';
import '../budget/budget_controller.dart';
import '../categories/edit_budget_dialog.dart';

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
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or create an envelope category first.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFill = isDark ? const Color(0xFF2C3034) : const Color(0xFFF3F1EC);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                color: isDark ? const Color(0xFF4A4E52) : const Color(0xFFBBB7AC),
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
                  color: isDark ? const Color(0xFF272B2E) : const Color(0xFFE8E5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentType = QuickAddType.outflow),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isOutflow ? AppColors.terracotta : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Outflow',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOutflow
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _currentType = QuickAddType.inflow),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: !isOutflow ? AppColors.sage : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Inflow',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: !isOutflow
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Numeric Amount Display Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF25292D) : const Color(0xFFF3F1EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                '${controller.currencySymbol} ${CurrencyFormatter.formatNumberString(_amountStr)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips (Only shown in Outflow mode)
          if (isOutflow) ...[
            if (controller.categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.terracotta),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No envelopes yet. Please add one first.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (_) => EditBudgetDialog(controller: controller),
                        );
                      },
                      child: const Text('+ Add Envelope', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              )
            else
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
                        backgroundColor: inputFill,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
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
            const SizedBox(height: 10),
          ],

          // Reason / Description TextField
          TextField(
            controller: _descriptionController,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: isOutflow
                  ? 'Description / Reason'
                  : 'Source Note (e.g. Salary, Stipend)',
              hintStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              filled: true,
              fillColor: inputFill,
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
              _buildKeypadRow(['1', '2', '3'], isDark),
              const SizedBox(height: 8),
              _buildKeypadRow(['4', '5', '6'], isDark),
              const SizedBox(height: 8),
              _buildKeypadRow(['7', '8', '9'], isDark),
              const SizedBox(height: 8),
              _buildKeypadRow(['.', '0', 'del'], isDark),
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

  Widget _buildKeypadRow(List<String> keys, bool isDark) {
    return Row(
      children: keys.map((key) {
        final isDel = key == 'del';
        final keyBg = isDel
            ? (isDark ? const Color(0xFF33383D) : const Color(0xFFDDD9CF))
            : (isDark ? const Color(0xFF262A2E) : const Color(0xFFEFECE5));

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onKeyPress(key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: keyBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isDel
                      ? Icon(
                          Icons.backspace_outlined,
                          size: 19,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        )
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
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
