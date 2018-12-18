import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event_create_request.jser.dart';

class EventCreateRequest {
  @Alias("name")
  String eventName;
  @Alias("description")
  String eventDescription;
  @Alias("image_url")
  String eventImageURL;
  @Alias("start_time")
  String eventStartTime;
  @Alias("end_time")
  String eventEndTime;
  @Alias("all_day")
  bool allDayEvent;
  @Alias("venue_names")
  List<String> eventVenueNames;
  @Alias("bodies_id")
  List<String> eventBodiesID;
}

@GenSerializer()
class EventCreateRequestSerializer extends Serializer<EventCreateRequest> with _$EventCreateRequestSerializer {}