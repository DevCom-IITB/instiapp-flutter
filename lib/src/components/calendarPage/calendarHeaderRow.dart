// row conaining month dropdown button, today, filter button

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CalendarHeaderRow extends StatelessWidget {
  final VoidCallback onMonthTap;
  final VoidCallback onFilterTap;
  const CalendarHeaderRow({Key? key, required this.onMonthTap, required this.onFilterTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: Responsive.height(8, context),
                              children: [
                                GestureDetector(
                                  onTap: onMonthTap,
                                  child:Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: Responsive.width(12, context),
                                    children: [
                                      Text(
                                        'June 2026',
                                        style: TextStyle(
                                          color: const Color(
                                              0xFF306FDC) /* InstiApp-blue */,
                                          fontSize:
                                              Responsive.width(20, context),
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w600,
                                          height: 1.20,
                                          letterSpacing: 0.38,
                                        ),
                                      ),
                                      Container(
                                        width: Responsive.width(12, context),
                                        height: Responsive.height(35, context),
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                Responsive.height(12, context)),
                                        child: SvgPicture.asset(
                                          'assets/calendar/down.svg',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ),
                                
                                Container(
                                  width: Responsive.width(197, context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: Responsive.width(4, context),
                                    children: [
                                      Container(
                                        width: Responsive.width(70, context),
                                        height: Responsive.height(40, context),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(12, context),
                                            vertical:
                                                Responsive.height(4, context)),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width:
                                                  Responsive.width(1, context),
                                              color: const Color(
                                                  0xFFD2D5DA) /* instiappgrey3 */,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.width(185, context)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: Responsive.width(8, context),
                                          children: [
                                            Text(
                                              'Today',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: Responsive.width(
                                                    14, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w400,
                                                height: Responsive.height(
                                                    1.71, context),
                                                letterSpacing: Responsive.width(
                                                    0.38, context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: onFilterTap,
                                        // onTap: (){
                                        //   showModalBottomSheet(
                                        //     context: context, 
                                        //     builder: (BuildContext context) {
                                        //       return Container(
                                        //         height: 200,
                                        //         child: Center(
                                        //           child: Text('Filter options go here'),
                                        //         ),
                                        //       );
                                        //     }
                                        //   );
                                        // },
                                        child:Container(
                                        height: Responsive.height(40, context),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(16, context),
                                            vertical: Responsive.height(
                                                10.95, context)),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFEFEFEF),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: Responsive.width(
                                                  1.37, context),
                                              color: const Color(0xFFD2D5DA),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.width(
                                                    68.42, context)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: Responsive.width(8, context),
                                          children: [
                                            SvgPicture.asset(
                                              'assets/calendar/filter.svg',
                                              fit: BoxFit.scaleDown,
                                            ),
                                            Text(
                                              'Filter',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xCC0F1620),
                                                fontSize: Responsive.width(
                                                    14, context),
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
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