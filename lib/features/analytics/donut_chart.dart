import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class DonutSlice {
  final String label;
  final double amount;
  final Color color;
  final double percentage;

  const DonutSlice({
    required this.label,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

class CustomDonutChart extends StatefulWidget {
  final List<DonutSlice> slices;
  final String defaultTitle;
  final double totalAmount;
  final String currencySymbol;
  final String defaultSubtitle;
  final String emptyMessage;

  const CustomDonutChart({
    super.key,
    required this.slices,
    required this.defaultTitle,
    required this.totalAmount,
    required this.currencySymbol,
    required this.defaultSubtitle,
    this.emptyMessage = 'No activity logged for this cycle.',
  });

  @override
  State<CustomDonutChart> createState() => _CustomDonutChartState();
}

class _CustomDonutChartState extends State<CustomDonutChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(CustomDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex != null && _selectedIndex! >= widget.slices.length) {
      _selectedIndex = null;
    }
  }

  void _selectSlice(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = null; // Toggle off if already selected
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.slices.isNotEmpty && widget.totalAmount > 0;

    final selectedSlice = (_selectedIndex != null && _selectedIndex! < widget.slices.length)
        ? widget.slices[_selectedIndex!]
        : null;

    final centerLabel = selectedSlice != null ? selectedSlice.label : widget.defaultTitle;
    final centerAmount = selectedSlice != null
        ? CurrencyFormatter.format(selectedSlice.amount, symbol: widget.currencySymbol)
        : CurrencyFormatter.format(widget.totalAmount, symbol: widget.currencySymbol);
    final centerSubtitle = selectedSlice != null
        ? '${selectedSlice.percentage.toStringAsFixed(0)}%'
        : widget.defaultSubtitle;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final centerColor = selectedSlice != null
        ? selectedSlice.color
        : (isDark ? Colors.white : AppColors.textPrimaryLight);

    return Column(
      children: [
        // Donut Canvas Area
        SizedBox(
          height: 190,
          width: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (hasData)
                GestureDetector(
                  onTapUp: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    // Center tap detection
                    final center = Offset(95, 95);
                    final touch = details.localPosition;
                    final distance = (touch - center).distance;
                    if (distance < 50) {
                      setState(() => _selectedIndex = null);
                    }
                  },
                  child: CustomPaint(
                    size: const Size(190, 190),
                    painter: _DonutChartPainter(
                      slices: widget.slices,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                )
              else
                CustomPaint(
                  size: const Size(190, 190),
                  painter: _EmptyDonutPainter(),
                ),

              // Center text readout
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = null),
                child: Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        centerLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        centerAmount,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: centerColor,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        centerSubtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: selectedSlice != null
                              ? selectedSlice.color
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Clickable Legend
        if (hasData)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(widget.slices.length, (idx) {
                final slice = widget.slices[idx];
                final isSelected = _selectedIndex == idx;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _selectSlice(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF33383D) : const Color(0xFFE8E5DC))
                          : (isDark ? const Color(0xFF24272A) : const Color(0xFFF3F1EB)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? slice.color
                            : (isDark ? const Color(0xFF383C40) : const Color(0xFFDCD7CC)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: slice.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slice.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${slice.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: slice.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.emptyMessage,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.slices,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;
    const selectedStrokeWidth = 18.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEFECE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.percentage / 100.0) * 2 * math.pi;
      if (sweepAngle <= 0.001) continue;

      final isSelected = selectedIndex == i;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? selectedStrokeWidth : strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Draw segment arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.slices != slices;
  }
}

class _EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    final paint = Paint()
      ..color = const Color(0xFFE5E2D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

