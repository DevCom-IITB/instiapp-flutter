// Widget for the complete "week view" (days + dates)

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './datesRowWidget.dart';
import './daysOfWeekWidget.dart';

class WeekDateUtils {
  static DateTime _findSunday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.sunday));
  }

  static List<DateTime> getDaysOfWeek(int weekOffset) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    final DateTime currentWeekSunday = _findSunday(today);
    final DateTime targetWeekSunday = currentWeekSunday.add(Duration(days: weekOffset * 7));

    return List.generate(7, (index) => targetWeekSunday.add(Duration(days: index)));
  }
}

class WeekViewWidget extends StatelessWidget {
  final int weekOffset; // 0 for current week, -1 for last week, 1 for next week, etc.
  const WeekViewWidget({
    Key? key,
    required this.weekOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

     final List<DateTime> weekDays = WeekDateUtils.getDaysOfWeek(weekOffset-1);
     final List<String> dates = weekDays.map((date) => date.day.toString()).toList();

      final now = DateTime.now();
      final todayIndex = weekOffset == 0 ? weekDays.indexWhere((date) => int.parse(date.day.toString()) == now.day) : null;

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
            datesArray: dates,
            selectedDateIndex: todayIndex, // Highlight today if weekOffset is 0
          ),
        ],
      ),
    );
  }
}
