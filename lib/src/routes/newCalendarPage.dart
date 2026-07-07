import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/components/calendarPage/eventsSectionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:InstiApp/src/api/response/calendar_feed_response.dart';
import '../components/calendarPage/monthSelectMenuWidget.dart';
import '../components/calendarPage/calendarHeaderRow.dart';
import '../components/calendarPage/calendarFilters.dart';
import '../components/calendarPage/listView.dart';
import '../components/calendarPage/weekViewScroll.dart';
import '../components/calendarPage/monthViewScroll.dart';
import '../components/calendarPage/monthGridCalendarScroll.dart';
import '../blocs/new_calendar_bloc.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  String bodyID = "";
  bool searchMode = false;
  CalendarFeedResponse? _calendarResponse;
  late final NewCalendarCubit _calendarCubit;
  String _selectedView = 'day';
  bool _showMonthSelector = false;
  int _filterVersion = 0;
// inside _ExplorePageState
  final ScrollController _listController = ScrollController();
  double _maxScrollOffset = double.infinity;
  final double _clampFraction = 0.4; // change to desired fraction (0.0 - 1.0)

  final PageController _weekPageController = PageController(initialPage: 10000);
  final PageController _monthPageController =
      PageController(initialPage: 10000);

  void _onTodayTap() {
    _calendarCubit.resetToToday();
    if (_weekPageController.hasClients) {
      _weekPageController.animateToPage(
        10000,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    if (_monthPageController.hasClients) {
      _monthPageController.animateToPage(
        10000,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  DateTime _findSunday(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  int _getWeekOffset(DateTime targetDate) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime currentWeekSunday = _findSunday(today);
    final DateTime targetWeekSunday = _findSunday(targetDate);
    final int differenceInDays =
        targetWeekSunday.difference(currentWeekSunday).inDays;
    return (differenceInDays / 7).round();
  }

  Future<void> _fetchCalendarFeed() async {
    final bloc = BlocProvider.of(context)!.bloc;

    var sessionHeader = bloc.getSessionIdHeader();
    if (sessionHeader.isEmpty) {
      try {
        await bloc.session
            .firstWhere((session) => session?.sessionid?.isNotEmpty == true)
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
      sessionHeader = bloc.getSessionIdHeader();
    }

    if (sessionHeader.isEmpty) {
      debugPrint('Calendar feed skipped: missing session cookie.');
      if (mounted) {
        setState(() {
          _calendarResponse = CalendarFeedResponse(items: []);
        });
      }
      return;
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final isoFormat = [yyyy, '-', mm, '-', dd];

    try {
      print('hellllo');
      print(start);
      print(end);
      print(isoFormat);

      final response = await bloc.getCalendarFeedCombined(
        sessionHeader,
        formatDate(start, isoFormat),
        formatDate(end, isoFormat),
        'Asia/Kolkata',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _calendarResponse = response;
      });
    } catch (e) {
      debugPrint('Dio error type: ${e.toString()}');
      if (mounted) {
        setState(() {
          _calendarResponse = CalendarFeedResponse(items: []);
        });
      }
    }
  }

  late AnimationController _controller;

  // Maximum height the new widget can expand to
  final double _maxHeight = 330.0;
  // Initial height of the Week View widget
  final double _weekViewHeight = 80.0;
  @override
  void initState() {
    super.initState();
    _calendarCubit = NewCalendarCubit();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCalendarFeed();
    });

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
    _calendarCubit.dispose();
    _controller.dispose();
    _listController.dispose();
    _weekPageController.dispose();
    _monthPageController.dispose();

    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value += details.primaryDelta! / _maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    // Snap to expanded or collapsed state based on how far the user dragged
    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return NewCalendarScope(
      cubit: _calendarCubit,
      child: AnimatedBuilder(
        animation: _calendarCubit,
        builder: (context, _) {
          final calendarCubit = NewCalendarScope.of(context);
          final visibleDate = calendarCubit.currentDate;

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
                                          borderRadius:
                                              BorderRadius.circular(25),
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
                                          print('Icon tapped!');

                                          var value = await showMenu<String>(
                                            context: context,
                                            position: RelativeRect.fromLTRB(
                                              MediaQuery.of(context).size.width,
                                              kToolbarHeight,
                                              0,
                                              0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            items: <PopupMenuEntry<String>>[
                                              PopupMenuItem(
                                                value: 'day',
                                                height: 45,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.view_day,
                                                        size: 28),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "Day",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'month',
                                                height: 45,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                        Icons
                                                            .calendar_view_month,
                                                        size: 28),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "Month",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuDivider(
                                                height: 2,
                                              ),
                                              PopupMenuItem(
                                                value: 'list',
                                                height: 45,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.list, size: 28),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "List",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                          if (value != null) {
                                            setState(() {
                                              _selectedView = value;
                                            });
                                          }
                                          print(
                                              'Selected: $_selectedView and value: $value');
                                        },
                                        child: SizedBox(
                                          width: Responsive.width(16, context),
                                          height:
                                              Responsive.height(16, context),
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
                      padding: _selectedView == 'list'
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              bottom: Responsive.height(12, context)),
                      decoration: BoxDecoration(
                        border: (_selectedView != 'list')
                            ? Border(
                                bottom: BorderSide(
                                  color: const Color(0xFFD2D5DA),
                                  width: Responsive.height(1, context),
                                ),
                              )
                            : null,
                      ),
                      child: _selectedView == 'list'
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.width(16, context)),
                              child: Column(
                                children: [
                                  CalendarHeaderRow(
                                    currentDate: visibleDate,
                                    onMonthTap: () {
                                      print('Month header tapped');
                                      setState(() {
                                        _showMonthSelector =
                                            !_showMonthSelector;
                                      });
                                    },
                                    onFilterTap: () async {
                                       await showCalendarFiltersBottomSheet(context);
                                       if (mounted) {
                                         setState(() {
                                           _filterVersion++;
                                         });
                                       }
                                     },
                                    onTodayTap: _onTodayTap,
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: _showMonthSelector
                                        ? MonthSelectMenuWidget(
                                            selectedMonth: visibleDate.month,
                                            onMonthSelected: (monthIndex) {
                                              final now = DateTime.now();
                                              final currentSelected =
                                                  calendarCubit.selectedDate;
                                              // int day = currentSelected.day;
                                              int day = 1;
                                              final lastDayOfTargetMonth =
                                                  DateTime(currentSelected.year,
                                                          monthIndex + 1, 0)
                                                      .day;
                                              if (day > lastDayOfTargetMonth) {
                                                day = lastDayOfTargetMonth;
                                              }
                                              final targetDate = DateTime(
                                                  currentSelected.year,
                                                  monthIndex,
                                                  day);
                                              calendarCubit
                                                  .selectDate(targetDate);

                                              final int monthOffset =
                                                  (currentSelected.year -
                                                              now.year) *
                                                          12 +
                                                      (monthIndex - now.month);
                                              if (_monthPageController
                                                  .hasClients) {
                                                _monthPageController
                                                    .animateToPage(
                                                  10000 + monthOffset,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }

                                              final int weekOffset =
                                                  _getWeekOffset(targetDate);
                                              if (_weekPageController
                                                  .hasClients) {
                                                _weekPageController
                                                    .animateToPage(
                                                  10000 + weekOffset,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                          )
                                        : const SizedBox(),
                                  )
                                ],
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
                                      horizontal:
                                          Responsive.width(16, context)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: Responsive.height(16, context),
                                    children: [
                                      CalendarHeaderRow(
                                        currentDate: visibleDate,
                                        onMonthTap: () {
                                          print('Month header tapped');
                                          setState(() {
                                            _showMonthSelector =
                                                !_showMonthSelector;
                                          });
                                        },
                                        onFilterTap: () async {
                                           await showCalendarFiltersBottomSheet(
                                               context);
                                           if (mounted) {
                                             setState(() {
                                               _filterVersion++;
                                             });
                                           }
                                         },
                                        onTodayTap: _onTodayTap,
                                      ),
                                      AnimatedSize(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        child: _showMonthSelector
                                            ? MonthSelectMenuWidget(
                                                selectedMonth:
                                                    visibleDate.month,
                                                onMonthSelected: (monthIndex) {
                                                  final now = DateTime.now();
                                                  final currentSelected =
                                                      calendarCubit
                                                          .selectedDate;
                                                  // int day = currentSelected.day;
                                                  int day = 1;
                                                  final lastDayOfTargetMonth =
                                                      DateTime(
                                                              currentSelected
                                                                  .year,
                                                              monthIndex + 1,
                                                              0)
                                                          .day;
                                                  if (day >
                                                      lastDayOfTargetMonth) {
                                                    day = lastDayOfTargetMonth;
                                                  }
                                                  final targetDate = DateTime(
                                                      currentSelected.year,
                                                      monthIndex,
                                                      day);
                                                  calendarCubit
                                                      .selectDate(targetDate);

                                                  final int monthOffset =
                                                      (currentSelected.year -
                                                                  now.year) *
                                                              12 +
                                                          (monthIndex -
                                                              now.month);
                                                  if (_monthPageController
                                                      .hasClients) {
                                                    _monthPageController
                                                        .animateToPage(
                                                      10000 + monthOffset,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }

                                                  final int weekOffset =
                                                      _getWeekOffset(
                                                          targetDate);
                                                  if (_weekPageController
                                                      .hasClients) {
                                                    _weekPageController
                                                        .animateToPage(
                                                      10000 + weekOffset,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  }
                                                },
                                              )
                                            : const SizedBox(),
                                      ),
                                      if (_selectedView == 'day'
                                          // ||
                                          //     _selectedView == 'month'
                                          )
                                        AnimatedBuilder(
                                          animation: _controller,
                                          builder: (context, child) {
                                            // if (_selectedView == 'month') {
                                            //   _controller.value = 0.2;
                                            // }
                                            double currentHeight =
                                                _weekViewHeight +
                                                    (_controller.value *
                                                        (_maxHeight -
                                                            _weekViewHeight));

                                            return Container(
                                              height: currentHeight,
                                              width: double.infinity,
                                              color: const Color(0xFFF6F6F6),
                                              child: Stack(
                                                children: [
                                                  Opacity(
                                                    opacity: (1.0 -
                                                            _controller.value)
                                                        .clamp(0.0, 1.0),
                                                    child: _controller.value <
                                                            0.9
                                                        ? WeekCalendarScroll(
                                                            pageController:
                                                                _weekPageController,
                                                            onDateSelected:
                                                                (DateTime
                                                                    date) {
                                                              calendarCubit
                                                                  .selectDate(
                                                                      date);
                                                            },
                                                            onVisibleDateChanged:
                                                                (DateTime
                                                                    date) {
                                                              calendarCubit
                                                                  .setVisibleDate(
                                                                      date);
                                                            },
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ),
                                                  Opacity(
                                                    opacity: _controller.value
                                                        .clamp(0.0, 1.0),
                                                    child: _controller.value >
                                                            0.1
                                                        ? SingleChildScrollView(
                                                            child:
                                                                MonthCalendarScroll(
                                                            pageController:
                                                                _monthPageController,
                                                            onDateSelected:
                                                                (DateTime
                                                                    date) {
                                                              calendarCubit
                                                                  .selectDate(
                                                                      date);
                                                            },
                                                            onVisibleDateChanged:
                                                                (DateTime
                                                                    date) {
                                                              calendarCubit
                                                                  .setVisibleDate(
                                                                      date);
                                                            },
                                                          ))
                                                        : const SizedBox
                                                            .shrink(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      else if (_selectedView == 'month')
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: _showMonthSelector
                                                ? Responsive.height(500, context)
                                                : Responsive.height(575, context),
                                          ),
                                          child: MonthGridCalendarScroll(
                                            filterVersion: _filterVersion,
                                            pageController: _monthPageController,
                                            onVisibleDateChanged: (DateTime date) {
                                              calendarCubit.setVisibleDate(date);
                                            },
                                          ),
                                        ),
                                      if (_selectedView != 'month' || (_selectedView == 'month' && !_showMonthSelector))
                                        GestureDetector(
                                          onVerticalDragUpdate:
                                              _handleDragUpdate,
                                          onVerticalDragEnd: _handleDragEnd,
                                          child: DragHandleWidget()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (_selectedView == 'list')
                      Expanded(
                        child: ListViewWidget(
                          key: ValueKey('${calendarCubit.selectedDate}_$_filterVersion'),
                          controller: _listController,
                          selectedDate: calendarCubit.selectedDate,
                        ),
                      )
                    else if (_selectedView == 'day')
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: Responsive.height(100, context)),
                          child: EventsSectionWidget(
                            key: ValueKey('${calendarCubit.selectedDate}_$_filterVersion'),
                            day: calendarCubit.selectedDate,
                          ),
                        ),
                      ),
                  ],
                )),
              ]));
        },
      ),
    );
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
