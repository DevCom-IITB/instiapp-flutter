// the component showing the name of the month in month selection menu

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class MonthNameBox extends StatelessWidget {
  final String monthName;
  const MonthNameBox({Key? key, required this.monthName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: Responsive.height(36, context),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10.80, vertical: 3.60),
        decoration: ShapeDecoration(
          color: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(monthName),
      ),
    );
  }
}
