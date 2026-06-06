// contains date, and events on that day

import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import '../../api/response/calendar_feed_response.dart';
import 'package:intl/intl.dart';

class EventsSectionWidget extends StatelessWidget {
  final CalendarFeedResponse? response;
  EventsSectionWidget({required this.response});

  @override
  Widget build(BuildContext context) {
    print('haha: ${response?.items}');
    // print each element in response.items
    response?.items.forEach((item) {
      print('item: ${item.title}, ${item.startTime}, ${item.endTime}');
    });
    return Column(
                
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Responsive.height(20, context),
                children: [
                  Container(
                    width: Responsive.width(380, context),
                    margin: EdgeInsets.only(top: Responsive.height(20, context)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // spacing: Responsive.height(12, context),
                      children: [
                        Container(
                          width: double.infinity,
                          // height: Responsive.height(36, context),
                          // padding: EdgeInsets.only(
                          //     bottom: Responsive.height(12, context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // spacing: Responsive.height(4, context),
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // spacing: Responsive.width(10, context),
                                  children: [
                                    Text(
                                      'Mon, 7th April',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: Responsive.width(16, context),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 1.50,
                                        letterSpacing: 0.38,
                                      ),
                                    ),
                                    Text(
                                      '${response?.items.length} events',
                                      style: TextStyle(
                                        color: const Color(
                                            0xFF7E8287) /* instiappgrey */,
                                        fontSize: Responsive.width(16, context),
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        letterSpacing: 0.38,
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
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Responsive.width(4, context),
                    children: [
                      
                        // All day events
                      ...(response?.items ?? []).map((item) {
                      if(!item.all_day) return SizedBox.shrink();  
                      return Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEFEFEF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFB7DC89),
                                shape: OvalBorder(),
                              ),
                            ),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: 12,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                      })
                    ]
                      
                    ,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Responsive.height(10, context),
                    // padding: EdgeInsets.only(top: Responsive.height(10, context)),
                    children: [
                      // all events
                      ...(response?.items ?? []).map((item) {
                      DateTime eventStart = DateTime.parse(item.startTime).toLocal();
                       String eventStartTimeString = DateFormat('hh:mma').format(eventStart);
                      DateTime eventEnd = DateTime.parse(item.endTime).toLocal();
                        String eventEndTimeString = DateFormat('hh:mma').format(eventEnd);
                      return Container(
                        // alignment: Alignment.center,
                        width: Responsive.width(380, context),
                        // height: Responsive.height(101, context),
                        padding: EdgeInsets.only(
                            top: Responsive.height(12, context),
                            left: Responsive.width(18, context),
                            right: Responsive.width(16, context),
                            bottom: Responsive.height(12, context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(
                                color: const Color(0xFF306FDC),
                                width: 6,
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      Responsive.height(16, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                ),
                              ),
                              Text(
                                '${eventStartTimeString} - ${eventEndTimeString}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      Responsive.height(12, context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.38,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  )
                ],
              );
  }
}
