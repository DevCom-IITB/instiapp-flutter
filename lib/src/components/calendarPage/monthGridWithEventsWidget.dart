import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:date_format/date_format.dart';
import '../../api/response/calendar_feed_response.dart';
import '../../api/model/calendar_item.dart';
import '../../blocs/new_calendar_bloc.dart';

class MonthGridWithEventsWidget extends StatefulWidget {
  final int monthOffset;
  final int filterVersion;
  const MonthGridWithEventsWidget({
    Key? key,
    required this.monthOffset,
    this.filterVersion = 0,
  }) : super(key: key);

  @override
  State<MonthGridWithEventsWidget> createState() => _MonthGridWithEventsWidgetState();
}

class _MonthGridWithEventsWidgetState extends State<MonthGridWithEventsWidget> {
  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  
  DateTime? _lastFetchedMonth;
  int? _lastFilterVersion;
  Future<CalendarFeedResponse?>? _eventsFuture;

  Future<CalendarFeedResponse?> _fetchEventsForMonth(DateTime currentDate) async {
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

    final start = DateTime(currentDate.year, currentDate.month, 1);
    final end = DateTime(currentDate.year, currentDate.month + 1, 1);
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
      debugPrint('Error fetching events for month: $e');
      return CalendarFeedResponse(items: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarCubit = NewCalendarScope.of(context);
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month + widget.monthOffset, 1);

    if (_lastFetchedMonth == null ||
        _lastFetchedMonth!.year != currentDate.year ||
        _lastFetchedMonth!.month != currentDate.month ||
        _lastFilterVersion != widget.filterVersion) {
      _lastFetchedMonth = currentDate;
      _lastFilterVersion = widget.filterVersion;
      _eventsFuture = _fetchEventsForMonth(currentDate);
    }

    // Day of the week for the 1st of the month (1 = Monday, 7 = Sunday)
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday;

    // Number of days in this month
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final totalDays = lastDayOfMonth.day;

    // Map Dart's weekday (1-7) to column index (0-6) where Sunday is 0:
    int firstColumn = weekdayOfFirst == 7 ? 0 : weekdayOfFirst;

    List<String> cells = [];
    for (int i = 0; i < firstColumn; i++) {
      cells.add('');
    }
    for (int i = 1; i <= totalDays; i++) {
      cells.add(i.toString());
    }
    while (cells.length % 7 != 0) {
      cells.add('');
    }

    List<List<String>> weeks = [];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    return FutureBuilder<CalendarFeedResponse?>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final response = snapshot.data ?? CalendarFeedResponse(items: []);

        return Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayHeader(context),
              ...weeks.map((week) => _buildWeekRow(context, week, currentDate, response, calendarCubit)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Responsive.height(10, context)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1)),
      ),
      child: Row(
        children: _dayLabels
            .map((label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: const Color(0x4C3C3C43),
                        fontSize: Responsive.width(14, context),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.07,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildWeekRow(BuildContext context, List<String> week, DateTime currentDate, CalendarFeedResponse response, NewCalendarCubit cubit) {
    final year = currentDate.year;
    final month = currentDate.month;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.height(8, context)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: week
            .map((dayStr) {
              if (dayStr.isEmpty) {
                return const Expanded(child: SizedBox.shrink());
              }
              final dayNum = int.parse(dayStr);
              final cellDate = DateTime(year, month, dayNum);
              final isSelected = cubit.isSelected(cellDate);
              final isToday = cellDate.year == today.year && cellDate.month == today.month && cellDate.day == today.day;

              // Filter events for this day
              final dayEvents = response.items.where((item) {
                final start = DateTime.parse(item.startTime).toLocal();
                final end = DateTime.parse(item.endTime).toLocal();

                final dayStart = DateTime(cellDate.year, cellDate.month, cellDate.day);
                final dayEnd = dayStart.add(const Duration(days: 1));

                return start.isBefore(dayEnd) && end.isAfter(dayStart);
              }).toList();

              return Expanded(
                child: _DateCell(
                  day: dayStr,
                  events: dayEvents,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () {
                    cubit.selectDate(cellDate);
                  },
                ),
              );
            })
            .toList(),
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final String day;
  final List<CalendarItem> events;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DateCell({
    required this.day,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  static final List<Color> _eventColors = [
    const Color(0xFFB7DC89),
    const Color(0xFFF6D88A),
    const Color(0xFF306FDC),
    const Color(0xFFECA3A3),
    const Color(0xFFA1E3F9),
  ];

  Color _getColorForEvent(CalendarItem item) {
    final index = item.uid.hashCode.abs() % _eventColors.length;
    return _eventColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minHeight: Responsive.height(70, context)),
        padding: EdgeInsets.symmetric(horizontal: Responsive.width(2, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: Responsive.height(4, context)),
              child: Container(
                width: Responsive.width(24, context),
                height: Responsive.width(24, context),
                alignment: Alignment.center,
                decoration: isSelected
                    ? const BoxDecoration(
                        color: Color(0xFF306FDC),
                        shape: BoxShape.circle,
                      )
                    : isToday
                        ? BoxDecoration(
                            border: Border.all(color: const Color(0xFF306FDC), width: 1.5),
                            shape: BoxShape.circle,
                          )
                        : null,
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF306FDC)
                            : Colors.black,
                    fontSize: Responsive.width(14, context),
                    fontFamily: 'DM Sans',
                    fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
            ...events.take(3).map((e) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.height(3, context)),
                  child: e.all_day
                      ? _PillEventLabel(event: e, color: _getColorForEvent(e))
                      : _BulletEventLabel(event: e, color: _getColorForEvent(e)),
                )),
            if (events.length > 3)
              Padding(
                padding: EdgeInsets.only(left: Responsive.width(4, context)),
                child: Text(
                  '+${events.length - 3} more',
                  style: TextStyle(
                    fontSize: Responsive.width(9, context),
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// All-day style chip — solid rounded pill
class _PillEventLabel extends StatelessWidget {
  final CalendarItem event;
  final Color color;

  const _PillEventLabel({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.width(5, context),
        vertical: Responsive.height(3, context),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Responsive.width(6, context)),
      ),
      child: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: Responsive.width(10, context),
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Timed-event style chip — left bar + label
class _BulletEventLabel extends StatelessWidget {
  final CalendarItem event;
  final Color color;

  const _BulletEventLabel({required this.event, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: Responsive.width(3, context),
          height: Responsive.height(11, context),
          color: color,
        ),
        SizedBox(width: Responsive.width(4, context)),
        Expanded(
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black87,
              fontSize: Responsive.width(10, context),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
