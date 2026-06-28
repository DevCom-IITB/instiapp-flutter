// this contains entire section of month selection menu

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './monthNameBox.dart';

class MonthSelectMenuWidget extends StatelessWidget {
  final int selectedMonth; // 1-12
  final ValueChanged<int> onMonthSelected;

  const MonthSelectMenuWidget({
    Key? key,
    required this.selectedMonth,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: Responsive.height(12, context),
          children: [
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Responsive.width(6.43, context),
                children: [
                  MonthNameBox(
                    monthName: 'Jan',
                    isSelected: selectedMonth == 1,
                    onTap: () {
                      onMonthSelected(1);
                      print('jan');
                    },
                  ),
                  MonthNameBox(
                    monthName: 'Feb',
                    isSelected: selectedMonth == 2,
                    onTap: () => onMonthSelected(2),
                  ),
                  MonthNameBox(
                    monthName: 'Mar',
                    isSelected: selectedMonth == 3,
                    onTap: () => onMonthSelected(3),
                  ),
                  MonthNameBox(
                    monthName: 'Apr',
                    isSelected: selectedMonth == 4,
                    onTap: () => onMonthSelected(4),
                  ),
                ]),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Responsive.width(6.43, context),
                children: [
                  MonthNameBox(
                    monthName: 'May',
                    isSelected: selectedMonth == 5,
                    onTap: () => onMonthSelected(5),
                  ),
                  MonthNameBox(
                    monthName: 'Jun',
                    isSelected: selectedMonth == 6,
                    onTap: () => onMonthSelected(6),
                  ),
                  MonthNameBox(
                    monthName: 'Jul',
                    isSelected: selectedMonth == 7,
                    onTap: () => onMonthSelected(7),
                  ),
                  MonthNameBox(
                    monthName: 'Aug',
                    isSelected: selectedMonth == 8,
                    onTap: () => onMonthSelected(8),
                  ),
                ]),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Responsive.width(6.43, context),
                children: [
                  MonthNameBox(
                    monthName: 'Sep',
                    isSelected: selectedMonth == 9,
                    onTap: () => onMonthSelected(9),
                  ),
                  MonthNameBox(
                    monthName: 'Oct',
                    isSelected: selectedMonth == 10,
                    onTap: () => onMonthSelected(10),
                  ),
                  MonthNameBox(
                    monthName: 'Nov',
                    isSelected: selectedMonth == 11,
                    onTap: () => onMonthSelected(11),
                  ),
                  MonthNameBox(
                    monthName: 'Dec',
                    isSelected: selectedMonth == 12,
                    onTap: () => onMonthSelected(12),
                  ),
                ]),
          ]),
    );
  }
}
