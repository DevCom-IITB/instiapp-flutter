import 'package:json_annotation/json_annotation.dart';
import 'package:InstiApp/src/api/model/calendar_item.dart';

part 'calendar_feed_response.g.dart';

@JsonSerializable()
class CalendarFeedResponse {
  final List<CalendarItem> items;

  CalendarFeedResponse({
    required this.items,
  });

  factory CalendarFeedResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CalendarFeedResponseFromJson(json);
}