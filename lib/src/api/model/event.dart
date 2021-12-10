import 'package:InstiApp/src/api/model/body.dart' as bdy;
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:date_format/date_format.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/http.dart';

part 'event.g.dart';

// UserEventStatus
enum UES {
  NotGoing,
  Interested,
  Going,
}

@JsonSerializable()
class Event {
  @JsonKey(name: "id")
  String? eventID;

  @JsonKey(name: "str_id")
  String? eventStrID;

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

  @JsonKey(name: "venues")
  List<Venue>? eventVenues;

  @JsonKey(name: "bodies")
  List<bdy.Body>? eventBodies;

  @JsonKey(name: "interested_count")
  int? eventInterestedCount;

  @JsonKey(name: "going_count")
  int? eventGoingCount;

  @JsonKey(name: "interested")
  List<User>? eventInterested;

  @JsonKey(name: "going")
  List<User>? eventGoing;

  @JsonKey(name: "website_url")
  String? eventWebsiteURL;

  @JsonKey(name: "user_ues")
  int? eventUserUesInt;

  @JsonKey(ignore: true)
  UES get eventUserUes => UES.values[eventUserUesInt ?? 0];

  @JsonKey(ignore: true)
  set eventUserUes(UES ues) {
    eventUserUesInt = ues.index;
  }

  @JsonKey(ignore: true)
  bool eventBigImage = false;

  DateTime? eventStartDate;

  @JsonKey(ignore: true)
  String getSubTitle() {
    String subtitle = "";

    DateTime startTime = DateTime.parse(eventStartTime!);
    DateTime endTime = DateTime.parse(eventEndTime!);
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
      subtitle +=
          formatDate(startTime.toLocal(), [dd, " ", M, " | ", HH, ":", nn]);
    }
    String eventVenueName = "";
    for (var venue in eventVenues!) {
      eventVenueName += ", ${venue.venueShortName}";
    }
    if (eventVenueName != "") {
      subtitle += " | ${eventVenueName.substring(2)}";
    }

    return subtitle;
  }

  Event({
    this.eventID,
    this.eventStrID,
    this.eventName,
    this.eventDescription,
    this.eventImageURL,
    this.eventStartTime,
    this.eventEndTime,
    this.allDayEvent,
    this.eventVenues,
    this.eventBodies,
    this.eventInterestedCount,
    this.eventGoingCount,
    this.eventInterested,
    this.eventGoing,
    this.eventWebsiteURL,
    this.eventUserUesInt,
  });

  factory Event.fromJson(Map<String, dynamic> json) =>
      _$EventFromJson(json);
      
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
