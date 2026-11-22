import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../budget/budget_controller.dart';
import '../analytics/analytics_screen.dart';
import '../goals/goals_screen.dart';
import '../home/home_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../templates/templates_screen.dart';

class MainShell extends StatefulWidget {
  final BudgetController controller;

  const MainShell({
    super.key,
    required this.controller,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _openQuickAdd() {
    QuickAddSheet.show(context, widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.charcoal),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // Screen body based on selected index
              IndexedStack(
                index: _currentIndex,
                children: [
                  HomeScreen(controller: controller),
                  AnalyticsScreen(controller: controller),
                  const SizedBox.shrink(), // Dummy for center button
                  GoalsScreen(controller: controller),
                  TemplatesScreen(controller: controller),
                ],
              ),

              // 5-Icon Floating Bottom Dock (No Text Labels)
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Home
                          _DockButton(
                            icon: Icons.home_rounded,
                            isSelected: _currentIndex == 0,
                            onTap: () => setState(() => _currentIndex = 0),
                          ),
                          // 2. Analytics
                          _DockButton(
                            icon: Icons.pie_chart_outline_rounded,
                            isSelected: _currentIndex == 1,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          // 3. Center Elevated + Quick-Add
                          GestureDetector(
                            onTap: _openQuickAdd,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.charcoal, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                          // 4. Goals & Targets
                          _DockButton(
                            icon: Icons.track_changes_rounded,
                            isSelected: _currentIndex == 3,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                          // 5. Presets
                          _DockButton(
                            icon: Icons.view_list_rounded,
                            isSelected: _currentIndex == 4,
                            onTap: () => setState(() => _currentIndex = 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 22,
        color: isSelected ? Colors.white : const Color(0xFF9EAAB2),
      ),
    );
  }
}


