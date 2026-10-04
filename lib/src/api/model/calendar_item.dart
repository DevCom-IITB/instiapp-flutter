import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'calendar_item.g.dart';

class PillStyle {
  final Color backgroundColor;
  final Color? borderColor;
  final Color? dotColor;
  final Color textColor;

  PillStyle({
    required this.backgroundColor,
    this.borderColor,
    this.dotColor,
    this.textColor = Colors.black,
  });
}

@JsonSerializable()
class CalendarItem {
  final String uid;
  final String title;
  final bool all_day;

  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'source')
  final String? source;

  @JsonKey(name: 'color')
  final String? color;

  @JsonKey(name: 'color_hint')
  final String? colorHint;

  @JsonKey(name: 'subsource')
  final String? subsource;

  /// Global map of full calendar colors (keyed by slug, id, or name in lowercase)
  static final Map<String, String> calendarColors = {};

  CalendarItem({
    required this.uid,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.all_day,
    this.location,
    this.source,
    this.color,
    this.colorHint,
    this.subsource,
  });

  static Color? parseColor(String? colorStr) {
    if (colorStr == null) return null;
    final trimmed = colorStr.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    const namedColors = <String, Color>{
      'yellow': Color(0xFFFBC02D),
      'red': Color(0xFFE53935),
      'blue': Color(0xFF1E88E5),
      'green': Color(0xFF43A047),
      'purple': Color(0xFF7178F4),
      'orange': Color(0xFFFB8C00),
      'pink': Color(0xFFD81B60),
      'teal': Color(0xFF00897B),
      'cyan': Color(0xFF00ACC1),
      'grey': Color(0xFF757575),
      'gray': Color(0xFF757575),
      'indigo': Color(0xFF3949AB),
      'amber': Color(0xFFFFB300),
      'brown': Color(0xFF6D4C41),
      'black': Colors.black,
      'white': Colors.white,
    };

    if (namedColors.containsKey(trimmed)) {
      return namedColors[trimmed];
    }

    String hex = trimmed;
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    } else if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }

    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    if (hex.length == 6) {
      hex = 'ff$hex';
    }

    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) {
        return Color(val);
      }
    }

    return null;
  }

  PillStyle get pillStyle {
    /*
    // PREVIOUS COLOR SCHEME (based on subsource):
    // 1. Resobin events -> Lectures N Labs
    if (uid.startsWith('resobin-')) {
      return PillStyle(
        backgroundColor: const Color(0xFFCDE7C7), // light green
      );
    }

    // 2. Check subsource
    final sub = subsource?.toLowerCase();
    if (sub == 'holidays') {
      return PillStyle(
        backgroundColor: const Color(0xFFEFEFEF), // grey
        dotColor: const Color(0xFF35BA61), // green dot
      );
    } else if (sub == 'exams') {
      return PillStyle(
        backgroundColor: const Color(0xFFFF7474), // orangish-red
        textColor: Colors.white,
      );
    } else if (sub == 'social-event-announcements') {
      return PillStyle(
        backgroundColor: const Color(0xFF5292FF), // light blue
        textColor: Colors.white,
      );
    } else if (sub == 'reminders') {
      return PillStyle(
        backgroundColor: Colors.white,
        borderColor: const Color(0xFFFF7474), // orangish-red border
        textColor: Colors.black,
      );
    }

    // 3. Default: Other all-day events
    return PillStyle(
      backgroundColor: const Color(0xFFEFEFEF), // grey
      dotColor: const Color(0xFFFFA159), // orange dot
    );
    */

    // NEW COLOR SCHEME:
    // 1. Resobin events -> Purple color
    final isResobin = uid.startsWith('resobin-') ||
        uid.startsWith('resobin:') ||
        (source?.toLowerCase() == 'resobin');
    if (isResobin) {
      const purple = Color(0xFF7178F4);
      return PillStyle(
        backgroundColor: purple,
        textColor: Colors.white,
      );
    }

    // 2. Color returned by API for the event or full calendar
    final rawColor = color ??
        colorHint ??
        (subsource != null ? calendarColors[subsource!.toLowerCase()] : null) ??
        (source != null ? calendarColors[source!.toLowerCase()] : null);

    final raw = rawColor?.trim().toLowerCase();
    final sub = subsource?.trim().toLowerCase();

    debugPrint(
        '[CalendarItem Color Debug] "$title" | color: $color | colorHint: $colorHint | source: $source | subsource: $subsource | rawColor: $rawColor');

    // Holidays (green): Grey pill (#EFEFEF) + Green dot (#35BA61)
    if (raw == 'green' ||
        raw == '#35ba61' ||
        raw == '35ba61' ||
        raw == '#b7dd8a' ||
        (raw == null && sub == 'holidays')) {
      return PillStyle(
        backgroundColor: const Color(0xFFEFEFEF), // grey
        dotColor: const Color(0xFF35BA61), // green dot
        textColor: Colors.black,
      );
    }

    // Exams (orangish-red): Solid orangish-red (#FF7474) with white text
    if (raw == 'red' ||
        raw == 'orangish-red' ||
        raw == 'orange-red' ||
        raw == '#ff7474' ||
        raw == 'ff7474' ||
        raw == '#ffa294' ||
        raw == '#e53935' ||
        raw == 'e53935' ||
        (raw == null && sub == 'exams')) {
      return PillStyle(
        backgroundColor: const Color(0xFFFF7474), // orangish-red
        textColor: Colors.white,
      );
    }

    // Social Events & Announcements (light blue): Solid light blue (#5292FF) with white text
    if (raw == 'blue' ||
        raw == 'light blue' ||
        raw == '#5292ff' ||
        raw == '5292ff' ||
        raw == '#cceff' ||
        (raw == null && sub == 'social-event-announcements')) {
      return PillStyle(
        backgroundColor: const Color(0xFF5292FF), // light blue
        textColor: Colors.white,
      );
    }

    // Reminders: White background, orangish-red border (#FF7474), black text
    if (raw == 'reminder' ||
        raw == 'reminders' ||
        sub == 'reminders') {
      return PillStyle(
        backgroundColor: Colors.white,
        borderColor: const Color(0xFFFF7474), // orangish-red border
        textColor: Colors.black,
      );
    }

    // Lectures & Labs (light yellow / light green)
    if (raw == 'yellow' ||
        raw == 'light yellow' ||
        raw == '#f9f4d5' ||
        raw == 'f9f4d5' ||
        (raw == null && sub == 'lectures-n-labs')) {
      return PillStyle(
        backgroundColor: const Color(0xFFF9F4D5), // light yellow
        textColor: Colors.black,
      );
    }
    if (raw == 'light green' || raw == '#cde7c7' || raw == 'cde7c7') {
      return PillStyle(
        backgroundColor: const Color(0xFFCDE7C7), // light green
        textColor: Colors.black,
      );
    }

    // Other All-Day Events (orange dot): Grey pill (#EFEFEF) + Orange dot (#FFA159)
    if (raw == 'orange' ||
        raw == '#ffa159' ||
        raw == 'ffa159' ||
        raw == '#ffb073') {
      return PillStyle(
        backgroundColor: const Color(0xFFEFEFEF), // grey
        dotColor: const Color(0xFFFFA159), // orange dot
        textColor: Colors.black,
      );
    }

    // Purple: Solid purple (#7178F4) with white text
    if (raw == 'purple' || raw == '#7178f4' || raw == '7178f4' || raw == '#8e24aa' || raw == '8e24aa') {
      return PillStyle(
        backgroundColor: const Color(0xFF7178F4),
        textColor: Colors.white,
      );
    }

    // Custom parsed color if a hex was returned
    final parsedColor = parseColor(rawColor);
    if (parsedColor != null) {
      final isLight = parsedColor.computeLuminance() > 0.5;
      return PillStyle(
        backgroundColor: parsedColor,
        textColor: isLight ? Colors.black : Colors.white,
      );
    }

    // Default fallback: Grey pill (#EFEFEF) + Orange dot (#FFA159)
    return PillStyle(
      backgroundColor: const Color(0xFFEFEFEF), // grey
      dotColor: const Color(0xFFFFA159), // orange dot
      textColor: Colors.black,
    );
  }

  bool isOnDay(DateTime day) {
    try {
      final start = DateTime.parse(startTime).toLocal();
      final end = DateTime.parse(endTime).toLocal();

      final targetDate = DateTime(day.year, day.month, day.day);
      final nextDate = targetDate.add(const Duration(days: 1));

      if (all_day) {
        final startDate = DateTime(start.year, start.month, start.day);
        var endDate = DateTime(end.year, end.month, end.day);

        // If end time is exactly midnight (00:00:00) on a subsequent day,
        // it means the event ended at 24:00 of the previous day (exclusive end).
        if (end.hour == 0 &&
            end.minute == 0 &&
            end.second == 0 &&
            end.isAfter(start)) {
          endDate = endDate.subtract(const Duration(days: 1));
        }

        return !targetDate.isBefore(startDate) && !targetDate.isAfter(endDate);
      } else {
        return (start.isBefore(nextDate) && end.isAfter(targetDate)) ||
            (start.year == day.year &&
                start.month == day.month &&
                start.day == day.day);
      }
    } catch (_) {
      return true;
    }
  }

  factory CalendarItem.fromJson(
    Map<String, dynamic> json,
  ) {
    debugPrint(
        '[CalendarItem.fromJson] "${json['title']}" -> start: ${json['start_time']}, end: ${json['end_time']}, color: ${json['color']}, color_hint: ${json['color_hint']}');
    return _$CalendarItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CalendarItemToJson(this);
}
