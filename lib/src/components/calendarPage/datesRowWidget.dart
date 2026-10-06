// widget showing only dates in a single row

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import '../../blocs/new_calendar_bloc.dart';

class DatesRowWidget extends StatelessWidget {
  final List<DateTime> datesArray;
  final int? selectedDateIndex; // Optional: index of the selected date
  final ValueChanged<DateTime>?
      onDateSelected; // Optional: callback when a date is selected
  const DatesRowWidget(
      {Key? key,
      required this.datesArray,
      this.selectedDateIndex,
      this.onDateSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarCubit = NewCalendarScope.of(context);
    final selectedIndex =
        selectedDateIndex ?? datesArray.indexWhere(calendarCubit.isSelected);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < datesArray.length; i++)
            _buildDateCell(context, i, selectedIndex, today, calendarCubit),
        ],
      ),
    );
  }

  Widget _buildDateCell(BuildContext context, int i, int selectedIndex,
      DateTime today, NewCalendarCubit calendarCubit) {
    final date = datesArray[i];
    final isSelected = selectedIndex == i;
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Expanded(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print('Tapped on date: $date');
              calendarCubit.selectDate(date);
              onDateSelected?.call(date);
            },
            child: Container(
              width: Responsive.width(44, context),
              height: Responsive.width(44, context),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF306FDC)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: (!isSelected && isToday)
                    ? Border.all(
                        color: const Color(0xFF306FDC),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF306FDC)
                            : Colors.black,
                    fontSize: Responsive.width(20, context),
                    fontFamily: 'DM Sans',
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    height: 1.01,
                    letterSpacing: 0.32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
