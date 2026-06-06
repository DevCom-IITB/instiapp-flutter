
import 'package:json_annotation/json_annotation.dart';

part 'calendar_item.g.dart';
@JsonSerializable()
class CalendarItem {
  final String uid;
  final String title;
  final bool all_day;

  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  CalendarItem({
    required this.uid,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.all_day,
  });

  factory CalendarItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CalendarItemFromJson(json);
}