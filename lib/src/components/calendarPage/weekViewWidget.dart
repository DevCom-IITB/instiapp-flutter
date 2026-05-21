// Widget for the complete "week view" (days + dates)

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './datesRowWidget.dart';
import './daysOfWeekWidget.dart';

class WeekViewWidget extends StatelessWidget {
  const WeekViewWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            datesArray: ['6', '7', '8', '9', '10', '11', '12'],
          ),
        ],
      ),
    );
  }
}
