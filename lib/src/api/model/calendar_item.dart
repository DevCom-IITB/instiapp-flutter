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

  @JsonKey(name: 'color_hint')
  final String? colorHint;

  @JsonKey(name: 'subsource')
  final String? subsource;

  CalendarItem({
    required this.uid,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.all_day,
    this.location,
    this.source,
    this.colorHint,
    this.subsource,
  });

  PillStyle get pillStyle {
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
  }

  factory CalendarItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CalendarItemFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarItemToJson(this);
}
