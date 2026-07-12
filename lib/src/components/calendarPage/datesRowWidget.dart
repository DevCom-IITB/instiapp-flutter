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

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < datesArray.length; i++)
            Expanded(
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final selectedDate = datesArray[i];
                      print('Tapped on date: $selectedDate');
                      calendarCubit.selectDate(selectedDate);
                      onDateSelected?.call(selectedDate);
                    },
                    child: Container(
                      width: Responsive.width(44, context),
                      height: Responsive.width(44, context),
                      decoration: ShapeDecoration(
                        color: selectedIndex == i
                            ? const Color(0xFF306FDC)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(83.95),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          datesArray[i].day.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedIndex == i
                                ? Colors.white
                                : Colors.black,
                            fontSize: Responsive.width(20, context),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.01,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
