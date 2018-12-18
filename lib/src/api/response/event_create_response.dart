import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event_create_response.jser.dart';

class EventCreateResponse {
  String result;
  String eventId;
}

@GenSerializer()
class EventCreateResponseSerializer extends Serializer<EventCreateResponse> with _$EventCreateResponseSerializer {}