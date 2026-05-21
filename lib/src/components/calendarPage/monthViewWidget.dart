import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './datesRowWidget.dart';
import './daysOfWeekWidget.dart';

class MonthViewWidget extends StatelessWidget {
  const MonthViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            datesArray: ['', '', '1', '2', '3', '4', '5'],
          ),
          DatesRowWidget(
            datesArray: ['6', '7', '8', '9', '10', '11', '12'],
          ),
          DatesRowWidget(
            datesArray: ['13', '14', '15', '16', '17', '18', '19'],
          ),
          DatesRowWidget(
            datesArray: ['20', '21', '22', '23', '24', '25', '26'],
          ),
          DatesRowWidget(
            datesArray: ['27', '28', '29', '30', '', '', ''],
          ),
        ],
      ),
    );
  }
}
