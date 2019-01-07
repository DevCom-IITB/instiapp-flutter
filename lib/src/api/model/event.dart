import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:date_format/date_format.dart';

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

  DateTime eventStartDate;

  String getSubTitle() {
    String subtitle = "";

    DateTime startTime = DateTime.parse(eventStartTime);
    DateTime endTime = DateTime.parse(eventEndTime);
    DateTime timeNow = DateTime.now();
    bool eventStarted = timeNow.compareTo(startTime) > 0;
    bool eventEnded = timeNow.compareTo(endTime) > 0;

    if (eventEnded)
      subtitle += "Ended | ";
    else if (eventStarted) {
      int difference =
          endTime.millisecondsSinceEpoch - timeNow.millisecondsSinceEpoch;
      int minutes = difference ~/ (60 * 1000) % 60;
      int hours = difference ~/ (60 * 60 * 1000) % 24;
      int days = difference ~/ (24 * 60 * 60 * 1000);
      String timeDiff = "";
      if (days > 0) timeDiff += "${days}D ";
      if (hours > 0) timeDiff += "${hours}H ";

      timeDiff += "${minutes}M";

      subtitle += "Ends in $timeDiff | ";
    }

    if (startTime != null) {
      subtitle += formatDate(startTime.toLocal(), [dd, " ", M, " | ", HH, ":", nn]);
    }
    String eventVenueName = "";
    for (var venue in eventVenues) {
      eventVenueName += ", ${venue.venueShortName}";
    }
    if (eventVenueName != "") {
      subtitle += " | ${eventVenueName.substring(2)}";
    }

    return subtitle;
  }
}

@GenSerializer()
class EventSerializer extends Serializer<Event> with _$EventSerializer {}