// import 'package:InstiApp/src/api/model/UserTag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_create_request.g.dart';

@JsonSerializable()
class EventCreateRequest {
  @JsonKey(name: "name")
  String? eventName;
  @JsonKey(name: "description")
  String? eventDescription;
  @JsonKey(name: "image_url")
  String? eventImageURL;
  @JsonKey(name: "start_time")
  String? eventStartTime;
  @JsonKey(name: "end_time")
  String? eventEndTime;
  @JsonKey(name: "all_day")
  bool? allDayEvent;
  @JsonKey(name: "venue_names")
  List<String>? eventVenueNames;
  @JsonKey(name: "bodies_id")
  List<String>? eventBodiesID;
  @JsonKey(name: "notify")
  bool? notify;
  @JsonKey(name: "user_tags")
  List<int>? eventUserTags;

  EventCreateRequest(
      {this.eventName,
      this.eventDescription,
      this.eventImageURL,
      this.eventStartTime,
      this.eventEndTime,
      this.allDayEvent,
      this.eventVenueNames,
      this.eventBodiesID,
      this.notify,
      this.eventUserTags});
  factory EventCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EventCreateRequestToJson(this);
}
