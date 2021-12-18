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

  EventCreateRequest(
      {this.eventName,
      this.eventDescription,
      this.eventImageURL,
      this.eventStartTime,
      this.eventEndTime,
      this.allDayEvent,
      this.eventVenueNames,
      this.eventBodiesID});
  factory EventCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EventCreateRequestToJson(this);
}
