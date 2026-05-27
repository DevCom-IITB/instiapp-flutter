import 'package:InstiApp/src/components/calendarPage/eventsSectionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter_svg/svg.dart';

import '../components/calendarPage/monthViewWidget.dart';
import '../components/calendarPage/weekViewWidget.dart';
import '../components/calendarPage/monthSelectMenuWidget.dart';
import '../components/calendarPage/calendarHeaderRow.dart';
import '../components/calendarPage/calendarFilters.dart';
import '../components/calendarPage/listView.dart';

String selected = 'day';
bool showMonthSelector = false;
double calendarHeight = 10;
bool monthViewExpanded = false;

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String bodyID = "";
  bool searchMode = false;
// inside _ExplorePageState
  final ScrollController _listController = ScrollController();
  double _maxScrollOffset = double.infinity;
  final double _clampFraction = 0.4; // change to desired fraction (0.0 - 1.0)

  @override
  void initState() {
    super.initState();

    // compute allowed max after first layout (the ListView's maxScrollExtent becomes available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listController.hasClients) {
        final maxExtent = _listController.position.maxScrollExtent;
        _maxScrollOffset = maxExtent * _clampFraction;
      }
    });

    // prevent going past the allowed offset
    _listController.addListener(() {
      if (_listController.hasClients &&
          _listController.offset > _maxScrollOffset) {
        _listController.jumpTo(_maxScrollOffset);
      }
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
        // backgroundColor: Color.from(alpha: 1, red: 0.965, green: 0.965, blue: 0.965),
        backgroundColor: Color(0xFFF6F6F6),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
              child: Column(
            spacing: Responsive.width(20, context),
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(16, context)),
                child: SafeArea(
                    bottom: false,
                    child: Column(children: [
                      // SizedBox(height: Responsive.height(10.5, context)),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text('My Calendar',
                                style: TextStyle(
                                  fontSize: Responsive.text(24, context),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                  color: Color.fromRGBO(15, 22, 32, 1),
                                )),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                                width: Responsive.width(52, context),
                                height: Responsive.height(52, context),
                                decoration: ShapeDecoration(
                                  color: const Color(0xCCEBEBEB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                // child: SizedBox(
                                //   width: Responsive.width(16, context),
                                //   height: Responsive.height(16, context),
                                //   child: SvgPicture.asset(
                                //     'assets/calendar/list.svg',
                                //     fit: BoxFit.scaleDown,
                                //   ),
                                // ),
                                child: GestureDetector(
                                  onTap: () async {
                                    // Handle tap event here
                                    print('Icon tapped!');

                                    final value = await showMenu<String>(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        MediaQuery.of(context).size.width,
                                        kToolbarHeight,
                                        0,
                                        0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      items: <PopupMenuEntry<String>>[
                                        PopupMenuItem(
                                          value: 'day',
                                          height: 45,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.view_day, size: 28),
                                              SizedBox(width: 12),
                                              Text(
                                                "Day",
                                                style: TextStyle(
                                                  // fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'month',
                                          height: 45,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.calendar_view_month,
                                                  size: 28),
                                              SizedBox(width: 12),
                                              Text(
                                                "Month",
                                                style: TextStyle(
                                                  // fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(
                                          height: 2,
                                          // thickness: 5,      // why no work :(
                                        ),
                                        PopupMenuItem(
                                          value: 'list',
                                          height: 45,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.list, size: 28),
                                              SizedBox(width: 12),
                                              Text(
                                                "List",
                                                style: TextStyle(
                                                  // fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                    if (value != null) {
                                      setState(() {
                                        selected = value;
                                      });
                                    }
                                    print(
                                        'Selected: $selected and value: $value');
                                  },
                                  child: SizedBox(
                                    width: Responsive.width(16, context),
                                    height: Responsive.height(16, context),
                                    child: SvgPicture.asset(
                                      'assets/calendar/list.svg',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ])),
              ),
              Container(
                width: double.infinity,
                padding: selected == 'list'
                    ? EdgeInsets.zero
                    : EdgeInsets.only(bottom: Responsive.height(12, context)),
                decoration: BoxDecoration(
                  border: (selected != 'list')
                      ? Border(
                          bottom: BorderSide(
                            color: const Color(0xFFD2D5DA),
                            width: Responsive.height(1, context),
                          ),
                        )
                      : null,
                ),
                child: selected == 'list'
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.width(16, context)),
                        child: CalendarHeaderRow(
                          onMonthTap: () {
                            print('Month header tapped');
                            setState(() {
                              showMonthSelector = !showMonthSelector;
                            });
                          },
                          onFilterTap: () {
                            showCalendarFiltersBottomSheet(context);
                          },
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: Responsive.height(16, context),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.width(16, context)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: Responsive.height(16, context),
                              children: [
                                CalendarHeaderRow(
                                  onMonthTap: () {
                                    print('Month header tapped');
                                    setState(() {
                                      showMonthSelector = !showMonthSelector;
                                    });
                                  },
                                  onFilterTap: () {
                                    showCalendarFiltersBottomSheet(context);
                                  },
                                ),

                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: showMonthSelector
                                      ? MonthSelectMenuWidget()
                                      : const SizedBox(),
                                ),

                                if (selected == 'day')
                                  WeekViewWidget()
                                else if (selected == 'month')
                                  MonthViewWidget(),
                                // month names shown view
                                // MonthSelectMenuWidget(),

                                // week view including days of week and dates
                                // WeekViewWidget(),

                                // month view
                                // MonthViewWidget(),

                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  height: calendarHeight,
                                  child: Column(
                                    children: [
                                      if (monthViewExpanded) MonthViewWidget(),
                                      if (selected != 'list')
                                        DragHandleWidget(),
                                    ],
                                  ),
                                ),

                                // DragHandleWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              if (selected == 'list')
                Expanded(
                  child: ListViewWidget(controller: _listController),
                )
              else
                EventsSectionWidget(),
            ],
          )),
        ]));
  }
}

// empty widget
class DragHandleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: Responsive.height(12, context),
      children: [
        Container(
          width: Responsive.width(50, context),
          height: Responsive.height(5, context),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFD2D5DA),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(Responsive.width(100, context)),
            ),
          ),
        ),
      ],
    );
  }
}
