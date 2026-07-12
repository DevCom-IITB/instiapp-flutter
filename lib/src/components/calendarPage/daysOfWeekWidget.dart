// widget showing Days (Sun to Sat) in row

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class DaysOfWeekWidget extends StatelessWidget {
  const DaysOfWeekWidget({Key? key}) : super(key: key);

  static const List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final day in _days)
            Expanded(
              child: Center(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0x4C3C3C43),
                    fontSize: Responsive.width(14, context),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    height: 1.08,
                    letterSpacing: -0.07,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
