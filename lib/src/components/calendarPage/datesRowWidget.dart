// widget showing only dates in a single row

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class DatesRowWidget extends StatelessWidget {
  final List<String> datesArray;
  final int? selectedDateIndex; // Optional: index of the selected date
  const DatesRowWidget({Key? key, required this.datesArray, this.selectedDateIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12.34,
              children: [
                
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 0 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 0 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 1 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[1],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 1 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 2 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[2],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 2 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 3 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[3],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 3 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 4 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[4],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 4 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 5 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[5],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 5 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Responsive.width(44, context),
                  height: Responsive.width(44, context),
                  decoration: ShapeDecoration(
                    // color: const Color(0xFF306FDC) /* InstiApp-blue */,
                    color: selectedDateIndex == 6 ? const Color(0xFF306FDC) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.95),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: Responsive.width(0, context),
                        top: Responsive.width(12.36, context),
                        child: SizedBox(
                          width: Responsive.width(43.86, context),
                          child: Text(
                            datesArray[6],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.white,
                              color: selectedDateIndex == 6 ? Colors.white : Colors.black,
                              fontSize: Responsive.width(20, context),
                              fontFamily: 'DM Sans',
                              // fontWeight: FontWeight.w700,
                              fontWeight: FontWeight.w400,
                              height: 1.01,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
                    ],
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
