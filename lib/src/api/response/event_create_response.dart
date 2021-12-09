import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event_create_response.g.dart';

class EventCreateResponse {
  String result;
  String eventId;

  EventCreateResponse({
    this.result,
    this.eventId,
  });
  factory EventCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$EventCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventCreateResponseToJson(this);
}

@GenSerializer()
class EventCreateResponseSerializer extends Serializer<EventCreateResponse>
    with _$EventCreateResponseSerializer {}
