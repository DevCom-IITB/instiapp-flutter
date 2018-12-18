import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'event.jser.dart';

class Event {
  @Alias("id")
  String eventID;

  @Alias("str_id")
  String eventStrID;

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

  @Alias("venues")
  List<Venue> eventVenues;

  @Alias("bodies")
  List<Body> eventBodies;

  @Alias("interested_count")
  int eventInterestedCount;

  @Alias("going_count")
  int eventGoingCount;

  @Alias("interested")
  List<User> eventInterested;

  @Alias("going")
  List<User> eventGoing;

  @Alias("website_url")
  String eventWebsiteURL;

  @Alias("user_ues")
  int eventUserUes;

  bool eventBigImage = false;
}

@GenSerializer()
class EventSerializer extends Serializer<Event> with _$EventSerializer {}