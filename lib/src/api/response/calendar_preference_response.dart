import 'package:json_annotation/json_annotation.dart';
import 'package:InstiApp/src/api/model/calendar_item.dart';

part 'calendar_preference_response.g.dart';


// response format is
// [
//   {
//     "show_instiapp_going":true,
//     "show_instiapp_followed_bodies":true,
//     "show_resobin":true,"notifications_enabled":true,
//     "created_at":"2026-05-21T17:20:37.856309+05:30",
//     "updated_at":"2026-05-21T17:20:37.856309+05:30"
//   }
// ]

@JsonSerializable()
class CalendarPreferencesResponse {
  
  final List<CalendarItem> items;

  CalendarPreferencesResponse({
    required this.items,
  });

  factory CalendarPreferencesResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CalendarPreferencesResponseFromJson(json);
}