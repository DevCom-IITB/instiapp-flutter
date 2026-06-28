import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './datesRowWidget.dart';
import './daysOfWeekWidget.dart';

class MonthDateUtils {
  /// Finds the closest past Sunday for any given date
  static DateTime _findSunday(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  /// Generates 35 days (5 weeks) for a specific month offset
  static List<DateTime> getDaysOfMonth(int monthOffset) {
    final DateTime now = DateTime.now();

    // 1. Calculate the target year and month based on the offset
    int targetMonth = now.month + monthOffset;
    int targetYear = now.year;

    // Handle year transitions (e.g., month 13 becomes January of next year)
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear += 1;
    }
    while (targetMonth < 1) {
      targetMonth += 12;
      targetYear -= 1;
    }

    // 2. Get the exact 1st day of that target month at midnight
    final DateTime firstDayOfMonth = DateTime(targetYear, targetMonth, 1);

    // 3. Find the Sunday that starts the grid (even if it belongs to the previous month)
    final DateTime startSunday = _findSunday(firstDayOfMonth);

    // 4. Generate exactly 35 days (5 rows of 7 days)
    return List.generate(35, (index) => startSunday.add(Duration(days: index)));
  }
}

class MonthViewWidget extends StatelessWidget {
  final int
      monthOffset; // 0 for current month, -1 for last month, 1 for next month, etc.
  final ValueChanged<DateTime>? onDateSelected;

  const MonthViewWidget(
      {Key? key, required this.monthOffset, this.onDateSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<DateTime> monthDays = MonthDateUtils.getDaysOfMonth(monthOffset);
    print(monthDays);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: Responsive.height(12, context),
        children: [
          DaysOfWeekWidget(),
          // dates
          DatesRowWidget(
            datesArray: monthDays.sublist(0, 7),
            onDateSelected: onDateSelected,
          ),
          DatesRowWidget(
            datesArray: monthDays.sublist(7, 14),
            onDateSelected: onDateSelected,
          ),
          DatesRowWidget(
            datesArray: monthDays.sublist(14, 21),
            onDateSelected: onDateSelected,
          ),
          DatesRowWidget(
            datesArray: monthDays.sublist(21, 28),
            onDateSelected: onDateSelected,
          ),
          DatesRowWidget(
            datesArray: monthDays.sublist(28, 35),
            onDateSelected: onDateSelected,
          ),
        ],
      ),
    );
  }
}
