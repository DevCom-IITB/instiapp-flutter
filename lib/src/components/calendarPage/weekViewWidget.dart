// Widget for the complete "week view" (days + dates)

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import '../../blocs/new_calendar_bloc.dart';
import './datesRowWidget.dart';
import './daysOfWeekWidget.dart';

class WeekDateUtils {
  static DateTime _findSunday(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  static List<DateTime> getDaysOfWeek(int weekOffset) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime currentWeekSunday = _findSunday(today);
    final DateTime targetWeekSunday =
        currentWeekSunday.add(Duration(days: weekOffset * 7));

    return List.generate(
        7, (index) => targetWeekSunday.add(Duration(days: index)));
  }
}

class WeekViewWidget extends StatelessWidget {
  final int
      weekOffset; // 0 for current week, -1 for last week, 1 for next week, etc.
  final ValueChanged<DateTime>?
      onDateSelected; // Optional: callback when a date is selected
  const WeekViewWidget({
    Key? key,
    required this.weekOffset,
    this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDays = WeekDateUtils.getDaysOfWeek(weekOffset);
    final todayIndex =
        weekDays.indexWhere(NewCalendarScope.of(context).isSelected);

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: Responsive.width(6, context),
        children: [
          // days of week
          DaysOfWeekWidget(),
          // dates
          DatesRowWidget(
            datesArray: weekDays,
            selectedDateIndex: todayIndex,
            onDateSelected: onDateSelected,
          ),
        ],
      ),
    );
  }
}
