// this contains entire section of month selection menu

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import './monthNameBox.dart';

class MonthSelectMenuWidget extends StatelessWidget {
  const MonthSelectMenuWidget({Key? key}) : super(key: key);

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
                  MonthNameBox(monthName: 'Jan'),
                  MonthNameBox(monthName: 'Feb'),
                  MonthNameBox(monthName: 'Mar'),
                  MonthNameBox(monthName: 'Apr'),
                ]),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Responsive.width(6.43, context),
                children: [
                  MonthNameBox(monthName: 'May'),
                  MonthNameBox(monthName: 'Jun'),
                  MonthNameBox(monthName: 'Jul'),
                  MonthNameBox(monthName: 'Aug'),
                ]),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: Responsive.width(6.43, context),
                children: [
                  MonthNameBox(monthName: 'Sep'),
                  MonthNameBox(monthName: 'Oct'),
                  MonthNameBox(monthName: 'Nov'),
                  MonthNameBox(monthName: 'Dec'),
                ]),
          ]),
    );
  }
}
