// contains date, and events on that day

import 'package:InstiApp/src/bloc_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import '../../api/response/calendar_feed_response.dart';
import 'package:intl/intl.dart';
import '../../blocs/new_calendar_bloc.dart';


class EventsSectionWidget extends StatefulWidget {
  final DateTime day;
  final String? mode;
  const EventsSectionWidget({Key? key, required this.day, this.mode})
      : super(key: key);

  @override
  State<EventsSectionWidget> createState() =>
      _EventsSectionWidgetState(day, mode);
}

class _EventsSectionWidgetState extends State<EventsSectionWidget> {
  final DateTime day;
  final String? mode;
  _EventsSectionWidgetState(this.day, this.mode);
  Future<CalendarFeedResponse?>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEvents();
  }

  @override
  void didUpdateWidget(covariant EventsSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      setState(() {
        _eventsFuture = _fetchEvents();
      });
    }
  }

  Future<CalendarFeedResponse?> _fetchEvents() async {
    final bloc = context.findAncestorWidgetOfExactType<BlocProvider>()?.bloc;
    if (bloc == null) return null;

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
      return CalendarFeedResponse(items: []);
    }

    final start = DateTime(widget.day.year, widget.day.month, widget.day.day);
    final end = start.add(const Duration(days: 1));
    final isoFormat = [yyyy, '-', mm, '-', dd];

    try {
      final response = await bloc.getCalendarFeedCombined(
        sessionHeader,
        formatDate(start, isoFormat),
        formatDate(end, isoFormat),
        'Asia/Kolkata',
      );
      if (response != null && response.items != null) {
        for (var item in response.items) {
          print(item.toJson());
        }
      }
      return response;
    } catch (e) {
      debugPrint('Error fetching events for date: $e');
      return CalendarFeedResponse(items: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CalendarFeedResponse?>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Error loading events'));
        }

        final response = snapshot.data!;

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
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${[
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ][day.weekday - 1]}, ${day.day}${day.day.toString().endsWith('1') ? 'st' : day.day.toString().endsWith('2') ? 'nd' : day.day.toString().endsWith('3') ? 'rd' : 'th'} ${DateFormat('MMM').format(day)}',
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
                                '${response.items.length} events',
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
            if (response.items.any((item) => item.all_day))
              SizedBox(
                width: Responsive.width(380, context),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // padding: EdgeInsets.only(left: ),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Responsive.width(4, context),
                    children: [
                      ...response.items.where((item) => item.all_day).map((item) {
                        final style = item.pillStyle;
                        return Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: ShapeDecoration(
                            color: style.backgroundColor,
                            shape: RoundedRectangleBorder(
                              side: style.borderColor != null
                                  ? BorderSide(color: style.borderColor!, width: 1.5)
                                  : BorderSide.none,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              if (style.dotColor != null)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: ShapeDecoration(
                                    color: style.dotColor,
                                    shape: OvalBorder(),
                                  ),
                                ),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: style.textColor,
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Responsive.height(10, context),
              children: [
                // all events
                ...response.items.where((item) => !item.all_day).map((item) {
                  DateTime eventStart =
                      DateTime.parse(item.startTime).toLocal();
                  String eventStartTimeString =
                      DateFormat('hh:mma').format(eventStart);
                  DateTime eventEnd = DateTime.parse(item.endTime).toLocal();
                  String eventEndTimeString =
                      DateFormat('hh:mma').format(eventEnd);
                  final style = item.pillStyle;
                  final indicatorColor = style.borderColor ?? style.dotColor ?? (style.backgroundColor == const Color(0xFFEFEFEF) ? const Color(0xFF7E8287) : style.backgroundColor);

                  return Container(
                    width: Responsive.width(380, context),
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
                          color: indicatorColor,
                          width: 6,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
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
                            fontSize: Responsive.height(16, context),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                        if (item.location != null && item.location!.isNotEmpty)
                          Text(
                            item.location!,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: Responsive.height(12, context),
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.38,
                            ),
                          ),
                        Text(
                          item.all_day
                              ? 'All Day'
                              : '${eventStartTimeString} - ${eventEndTimeString}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: Responsive.height(12, context),
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
            ),
          ],
        );
      },
    );
  }
}
