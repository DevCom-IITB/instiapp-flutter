// widget showing Days (Sun to Sat) in row

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class DaysOfWeekWidget extends StatelessWidget {
  const DaysOfWeekWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Responsive.width(18.47, context),
        children: [
          Container(
            width: Responsive.width(28, context),
            height: Responsive.width(15, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(10.68, context),
                  top: 0,
                  child: Text(
                    'S',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(33, context),
            height: Responsive.width(15, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(11.68, context),
                  top: 0,
                  child: Text(
                    'M',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(26.86, context),
            height: Responsive.width(15.11, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(9.52, context),
                  top: 0,
                  child: Text(
                    'T',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(25, context),
            height: Responsive.width(15, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(5.58, context),
                  top: 0,
                  child: Text(
                    'W',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(26.86, context),
            height: Responsive.width(15.11, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(8.68, context),
                  top: 0,
                  child: Text(
                    'T',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(23, context),
            height: Responsive.width(15, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(7.62, context),
                  top: 0,
                  child: Text(
                    'F',
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
              ],
            ),
          ),
          Container(
            width: Responsive.width(26.86, context),
            height: Responsive.width(15.11, context),
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.width(9.52, context),
                  top: 0,
                  child: Text(
                    'S',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
