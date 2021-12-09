import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event_create_request.g.dart';

class EventCreateRequest {
  @JsonKey("name")
  String eventName;
  @JsonKey("description")
  String eventDescription;
  @JsonKey("image_url")
  String eventImageURL;
  @JsonKey("start_time")
  String eventStartTime;
  @JsonKey("end_time")
  String eventEndTime;
  @JsonKey("all_day")
  bool allDayEvent;
  @JsonKey("venue_names")
  List<String> eventVenueNames;
  @JsonKey("bodies_id")
  List<String> eventBodiesID;

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

@GenSerializer()
class EventCreateRequestSerializer extends Serializer<EventCreateRequest>
    with _$EventCreateRequestSerializer {}
