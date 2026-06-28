// the component showing the name of the month in month selection menu

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class MonthNameBox extends StatelessWidget {
  final String monthName;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthNameBox({
    Key? key,
    required this.monthName,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: Responsive.height(36, context),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10.80, vertical: 3.60),
          decoration: ShapeDecoration(
            color: isSelected ? const Color(0xFF306FDC) : const Color(0xFFEFEFEF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            monthName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
