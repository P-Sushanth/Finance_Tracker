import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/template_model.dart';
import '../budget/budget_controller.dart';

class TemplatesScreen extends StatelessWidget {
  final BudgetController controller;

  const TemplatesScreen({
    super.key,
    required this.controller,
  });

  void _openAddOrEditDialog(BuildContext context, [TemplateModel? templateToEdit]) {
    showDialog(
      context: context,
      builder: (_) => _TemplateEditDialog(
        controller: controller,
        templateToEdit: templateToEdit,
      ),
    );
  }

  void _confirmDelete(BuildContext context, TemplateModel template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Preset',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${template.title}"?',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (template.id != null) {
                controller.deleteTemplate(template.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${template.title}"'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPreset(BuildContext context, TemplateModel template) async {
    HapticFeedback.mediumImpact();
    await controller.applyTemplate(template);

    final cat = controller.findCategoryById(template.categoryId);
    final isInvestment = cat?.type == CategoryType.investment;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isInvestment ? Icons.trending_up : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Applied ${CurrencyFormatter.format(template.defaultAmount, symbol: controller.currencySymbol)} to ${cat?.name ?? template.title}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: isInvestment ? AppColors.sage : AppColors.charcoal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRESETS & RECURRING',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1-Tap Templates',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddOrEditDialog(context),
                      icon: Icon(
                        Icons.add,
                        size: 16,
                        color: isDark ? Colors.white : AppColors.charcoal,
                      ),
                      label: Text(
                        'New Preset',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.charcoal,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2C3034) : const Color(0xFFEBE9E1),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Instantly log your recurring monthly expenses, SIP investments, and utility bills with a single tap.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Templates List
                if (controller.templates.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No recurring templates yet.\nTap "+ New Preset" to create one for your rent, SIPs, or bills.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.templates.map((template) {
                    final category = controller.findCategoryById(template.categoryId);
                    final isInvestment = category?.type == CategoryType.investment;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark ? AppColors.cardBorderDark : const Color(0xFFE5E2D9),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Category badge icon
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isInvestment
                                          ? (isDark ? const Color(0xFF1E3326) : AppColors.sageLight)
                                          : (isDark ? const Color(0xFF33221E) : const Color(0xFFF0EFEA)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isInvestment ? Icons.trending_up : Icons.arrow_outward_rounded,
                                      size: 18,
                                      color: isInvestment
                                          ? (isDark ? const Color(0xFF68B29A) : AppColors.sage)
                                          : AppColors.terracotta,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          template.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF2C3034) : const Color(0xFFEBE9E1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                category?.name ?? 'General',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? const Color(0xFFBDC4CC) : AppColors.textSecondaryLight,
                                                ),
                                              ),
                                            ),
                                            if (template.defaultDescription != null &&
                                                template.defaultDescription!.isNotEmpty) ...[
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  template.defaultDescription!,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: 18,
                                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _openAddOrEditDialog(context, template);
                                      } else if (val == 'delete') {
                                        _confirmDelete(context, template);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Edit Preset',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.terracotta),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.terracotta,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                height: 1,
                                color: isDark ? AppColors.cardBorderDark : const Color(0xFFEAE8E0),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AMOUNT',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        CurrencyFormatter.format(template.defaultAmount, symbol: controller.currencySymbol),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isInvestment
                                              ? (isDark ? const Color(0xFF68B29A) : AppColors.sage)
                                              : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInvestment
                                          ? (isDark ? const Color(0xFF3A634E) : AppColors.sage)
                                          : (isDark ? const Color(0xFF363C42) : AppColors.charcoal),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _applyPreset(context, template),
                                    icon: const Icon(Icons.bolt_rounded, size: 16),
                                    label: const Text(
                                      'Apply Now',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 70), // Bottom padding for dock
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateEditDialog extends StatefulWidget {
  final BudgetController controller;
  final TemplateModel? templateToEdit;

  const _TemplateEditDialog({
    required this.controller,
    this.templateToEdit,
  });

  @override
  State<_TemplateEditDialog> createState() => _TemplateEditDialogState();
}

class _TemplateEditDialogState extends State<_TemplateEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final edit = widget.templateToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _amountController = TextEditingController(
      text: edit != null && edit.defaultAmount > 0
          ? edit.defaultAmount.toStringAsFixed(0)
          : '',
    );
    _descriptionController = TextEditingController(text: edit?.defaultDescription ?? '');

    if (edit != null) {
      _selectedCategoryId = edit.categoryId;
    } else if (widget.controller.categories.isNotEmpty) {
      _selectedCategoryId = widget.controller.categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0.0;

    if (title.isEmpty || amount <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid title, amount and select a category.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final note = _descriptionController.text.trim();

    if (widget.templateToEdit != null) {
      final updated = widget.templateToEdit!.copyWith(
        title: title,
        categoryId: _selectedCategoryId!,
        defaultAmount: amount,
        defaultDescription: note.isNotEmpty ? note : null,
      );
      await widget.controller.updateTemplate(updated);
    } else {
      await widget.controller.createTemplate(
        title: title,
        categoryId: _selectedCategoryId!,
        defaultAmount: amount,
        defaultDescription: note.isNotEmpty ? note : null,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.templateToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        isEditing ? 'Edit Preset' : 'New Recurring Preset',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Preset Title',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                hintText: 'e.g. WiFi Bill, Index SIP, Rent',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Default Amount (${widget.controller.currencySymbol})',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                hintText: 'e.g. 15000',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Target Envelope Category',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF383D43) : const Color(0xFFE5E2D9),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedCategoryId,
                  dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  isExpanded: true,
                  hint: Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  items: widget.controller.categories.map((cat) {
                    final isInvestment = cat.type == CategoryType.investment;
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(
                            isInvestment ? Icons.trending_up : Icons.arrow_outward_rounded,
                            size: 16,
                            color: isInvestment ? (isDark ? const Color(0xFF68B29A) : AppColors.sage) : AppColors.terracotta,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategoryId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: 'Optional Note / Description',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                hintText: 'e.g. Broadband connection',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF262A2E) : const Color(0xFFF5F4F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.sage : AppColors.charcoal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _handleSave,
          child: Text(isEditing ? 'Save Changes' : 'Create Preset', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

