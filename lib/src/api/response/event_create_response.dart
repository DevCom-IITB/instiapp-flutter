import 'package:json_annotation/json_annotation.dart';

part 'event_create_response.g.dart';

@JsonSerializable()
class EventCreateResponse {
  String? result;

  @JsonKey(name: "id")
  String? eventId;

  EventCreateResponse({
    this.result,
    this.eventId,
  });
  factory EventCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$EventCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventCreateResponseToJson(this);
}
