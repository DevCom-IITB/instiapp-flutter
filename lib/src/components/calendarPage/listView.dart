import 'package:flutter/material.dart';
import 'eventsSectionWidget.dart';
import '../../api/response/calendar_feed_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class ListViewWidget extends StatelessWidget {
  final ScrollController? controller;
  final DateTime selectedDate;

  const ListViewWidget({
    Key? key,
    this.controller,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // month of selcted date
    // DateTime month = DateTime(selectedDate.year, selectedDate.month, 1);
    // 2nd date of this month

    Future<CalendarFeedResponse?> _fetchEventsForDay(DateTime day) async {
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

      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final isoFormat = [yyyy, '-', mm, '-', dd];

      try {
        final response = await bloc.getCalendarFeedCombined(
          sessionHeader,
          formatDate(start, isoFormat),
          formatDate(end, isoFormat),
          'Asia/Kolkata',
        );
        return response;
      } catch (e) {
        debugPrint('Error fetching events for date: $e');
        return CalendarFeedResponse(items: []);
      }
    }

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        Responsive.width(16, context),
        Responsive.height(0, context),
        Responsive.width(16, context),
        Responsive.height(50, context),
      ),
      // fetch events here for each day and if no event then dont add widget
      children: [
        for (int i = 1; i < 31; i++)
          FutureBuilder<CalendarFeedResponse?>(
            future: _fetchEventsForDay(
                DateTime(selectedDate.year, selectedDate.month, i)),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data?.items != null &&
                  snapshot.data!.items!.isNotEmpty) {
                return EventsSectionWidget(
                  key: ValueKey(
                      DateTime(selectedDate.year, selectedDate.month, i)),
                  day: DateTime(selectedDate.year, selectedDate.month, i),
                );
              }
              return SizedBox.shrink();
            },
          ),
      ],
      // children: [
      //   EventsSectionWidget(
      //     key: ValueKey(selectedDate),
      //     selectedDate: selectedDate,
      //   ),
      // ],
    );
  }
}
