import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  /// Returns current month string in 'YYYY-MM' format (e.g. '2026-11')
  static String getCurrentCycleMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateFormat('yyyy-MM').format(d);
  }

  /// Determines the cycle month string ('YYYY-MM') for a given date and cycle start day.
  /// If cycleStartDay is 1, it matches the calendar month.
  /// If cycleStartDay > 1 and date.day < cycleStartDay, it belongs to the previous month's cycle.
  static String getCycleMonthForDate(DateTime date, int cycleStartDay) {
    if (cycleStartDay <= 1) {
      return DateFormat('yyyy-MM').format(date);
    }
    if (date.day >= cycleStartDay) {
      return DateFormat('yyyy-MM').format(date);
    } else {
      final prevMonthDate = DateTime(date.year, date.month - 1, 1);
      return DateFormat('yyyy-MM').format(prevMonthDate);
    }
  }

  /// Returns user-friendly month title (e.g. 'November 2026')
  static String formatMonthTitle(String cycleMonth) {
    try {
      final parts = cycleMonth.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (_) {}
    return cycleMonth;
  }

  /// Returns user-friendly date range for a cycle month (e.g., "Nov 1 – Nov 30" or "Oct 25 – Nov 24")
  static String getCycleRangeString(String cycleMonth, int cycleStartDay) {
    try {
      final parts = cycleMonth.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        if (cycleStartDay <= 1) {
          final startDate = DateTime(year, month, 1);
          final endDate = DateTime(year, month + 1, 0);
          return '${DateFormat('MMM d').format(startDate)} – ${DateFormat('MMM d').format(endDate)}';
        } else {
          final startDate = DateTime(year, month, cycleStartDay);
          final endDate = DateTime(year, month + 1, cycleStartDay - 1);
          return '${DateFormat('MMM d').format(startDate)} – ${DateFormat('MMM d').format(endDate)}';
        }
      }
    } catch (_) {}
    return formatMonthTitle(cycleMonth);
  }

  /// Calculates current day of month and total days in month
  /// Returns "Day X / Y"
  static String getCycleProgressString([DateTime? date]) {
    final now = date ?? DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return 'Day ${now.day} / $totalDays';
  }

  /// Returns a list of past N cycle months starting from current month going back
  static List<String> getRecentCycleMonths([int count = 6, DateTime? fromDate]) {
    final now = fromDate ?? DateTime.now();
    final List<String> months = [];
    for (int i = 0; i < count; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('yyyy-MM').format(d));
    }
    return months;
  }

  /// Formats transaction timestamp into readable format (e.g. 'Today, 4:30 PM' or 'Nov 20, 2:15 PM')
  static String formatTransactionTime(int timestampMillis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    final now = DateTime.now();

    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday = dt.year == now.year && dt.month == now.month && dt.day == now.day - 1;

    final timeStr = DateFormat('h:mm a').format(dt);

    if (isToday) {
      return 'Today, $timeStr';
    } else if (isYesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return DateFormat('MMM d, h:mm a').format(dt);
    }
  }
}
