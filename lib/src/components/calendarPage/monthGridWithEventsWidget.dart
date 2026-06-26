import 'package:flutter/material.dart';
import '../../utils/responsivenew.dart';

class MonthGridWithEventsWidget extends StatelessWidget {
  const MonthGridWithEventsWidget({Key? key}) : super(key: key);

  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Hardcoded June 2025 grid (1st is a Sunday, month has 30 days).
  // '' = blank cell (no date in that slot).
  static const List<List<String>> _weeks = [
    ['1', '2', '3', '4', '5', '6', '7'],
    ['8', '9', '10', '11', '12', '13', '14'],
    ['15', '16', '17', '18', '19', '20', '21'],
    ['22', '23', '24', '25', '26', '27', '28'],
    ['29', '30', '', '', '', '', ''],
  ];

  // Hardcoded demo events keyed by day-of-month, just to show chip styles.
  static final Map<String, List<_GridEvent>> _events = {
    '2': [
      const _GridEvent('Independence Day', color: Color(0xFFB7DC89)),
    ],
    '4': [
      const _GridEvent('HS Exam', color: Color(0xFFF6D88A)),
      const _GridEvent('Mood Meet', color: Color(0xFF306FDC), isBullet: true),
      const _GridEvent('Mood Meet', color: Color(0xFF306FDC), isBullet: true),
    ],
    '17': [
      const _GridEvent('Cultural Fest', color: Color(0xFFB7DC89)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(context),
          ..._weeks.map((week) => _buildWeekRow(context, week)),
        ],
      ),
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

  Widget _buildWeekRow(BuildContext context, List<String> week) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.height(8, context)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: week
            .map((day) => Expanded(
                  child: _DateCell(
                    day: day,
                    events: day.isEmpty ? const [] : (_events[day] ?? const []),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _GridEvent {
  final String label;
  final Color color;
  final bool isBullet;
  const _GridEvent(this.label, {required this.color, this.isBullet = false});
}

class _DateCell extends StatelessWidget {
  final String day;
  final List<_GridEvent> events;

  const _DateCell({required this.day, required this.events});

  @override
  Widget build(BuildContext context) {
    if (day.isEmpty) {
      return SizedBox(height: Responsive.height(70, context));
    }

    return Container(
      constraints: BoxConstraints(minHeight: Responsive.height(70, context)),
      padding: EdgeInsets.symmetric(horizontal: Responsive.width(2, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.height(4, context)),
            child: Text(
              day,
              style: TextStyle(
                color: Colors.black,
                fontSize: Responsive.width(15, context),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...events.map((e) => Padding(
                padding: EdgeInsets.only(bottom: Responsive.height(3, context)),
                child: e.isBullet
                    ? _BulletEventLabel(event: e)
                    : _PillEventLabel(event: e),
              )),
        ],
      ),
    );
  }
}

// All-day style chip — solid rounded pill, e.g. "Independence Day", "HS Exam".
class _PillEventLabel extends StatelessWidget {
  final _GridEvent event;
  const _PillEventLabel({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.width(5, context),
        vertical: Responsive.height(3, context),
      ),
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(Responsive.width(6, context)),
      ),
      child: Text(
        event.label,
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

// Timed-event style chip — left bar + label, e.g. "Mood Meet" entries.
class _BulletEventLabel extends StatelessWidget {
  final _GridEvent event;
  const _BulletEventLabel({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: Responsive.width(3, context),
          height: Responsive.height(11, context),
          color: event.color,
        ),
        SizedBox(width: Responsive.width(4, context)),
        Expanded(
          child: Text(
            event.label,
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
