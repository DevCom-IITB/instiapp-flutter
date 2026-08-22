import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(name: "show_all_events")
  bool? showAllEvents;

  @JsonKey(name: "show_instiapp_going")
  bool? showInstiappGoing;

  @JsonKey(name: "show_instiapp_followed_bodies")
  bool? showInstiappFollowedBodies;

  @JsonKey(name: "show_resobin")
  bool? showResobin;

  @JsonKey(name: "notifications_enabled")
  bool? notificationsEnabled;

  CalendarPreferencesResponse({
    this.showAllEvents,
    this.showInstiappGoing,
    this.showInstiappFollowedBodies,
    this.showResobin,
    this.notificationsEnabled,
  });

  factory CalendarPreferencesResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CalendarPreferencesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarPreferencesResponseToJson(this);
}