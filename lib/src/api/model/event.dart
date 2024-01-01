import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/offeredAchievements.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as elt;

import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

// UserEventStatus
enum UES {
  NotGoing,
  Interested,
  Going,
}

@JsonSerializable()
class Event extends elt.Event {
  @JsonKey(name: "id")
  String? eventID;

  @JsonKey(name: "str_id")
  String? eventStrID;

  @JsonKey(name: "name")
  String? eventName;

  @JsonKey(name: "description")
  String? eventDescription;

  @JsonKey(name: "verification_bodies")
  List<Body>? verificationBodies;

  @JsonKey(name: "longdescription")
  String? eventLongDescription;

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
  List<Body>? eventBodies;

  @JsonKey(name: "offered_achievements")
  List<OfferedAchievements>? eventOfferedAchievements;

  @JsonKey(name: "interested_count")
  int eventInterestedCount;

  @JsonKey(name: "going_count")
  int eventGoingCount;

  @JsonKey(name: "interested")
  List<User>? eventInterested;

  @JsonKey(name: "going")
  List<User>? eventGoing;

  @JsonKey(name: "website_url")
  String? eventWebsiteURL;

  @JsonKey(name: "user_ues")
  int? eventUserUesInt;

  @JsonKey(name: "user_tags")
  List<int>? eventUserTags;

  @JsonKey(name: "event_interest")
  List<Interest>? eventInterest;

  @JsonKey(ignore: true)
  UES get eventUserUes => UES.values[eventUserUesInt ?? 0];

  set eventUserUes(UES ues) {
    eventUserUesInt = ues.index;
  }

  @JsonKey(ignore: true)
  bool eventBigImage = false;

  DateTime? eventStartDate;

  String getSubTitle() {
    String subtitle = "";

    DateTime? startTime;
    if (eventStartTime != null) {
      startTime = DateTime.parse(eventStartTime!);
    }

    DateTime endTime = DateTime.parse(eventEndTime!);
    DateTime timeNow = DateTime.now();
    bool eventStarted = timeNow.compareTo(startTime ?? timeNow) > 0;
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

  Event(
      {this.eventID,
      this.eventStrID,
      this.eventName,
      this.verificationBodies,
      this.eventDescription,
      this.eventImageURL,
      this.eventStartTime,
      this.eventEndTime,
      this.allDayEvent,
      this.eventVenues,
      this.eventBodies,
      this.eventOfferedAchievements,
      this.eventInterestedCount = 0,
      this.eventGoingCount = 0,
      this.eventUserTags,
      this.eventInterested,
      this.eventGoing,
      this.eventWebsiteURL,
      this.eventUserUesInt,
      this.eventInterest})
      : super(
          date: DateTime.parse(eventStartTime!),
          title: eventName,
          description: eventDescription,
          location: eventVenues?.map((e) => e.venueName).toList().join(", "),
          icon: eventImageURL == null
              ? null
              : Image(image: NetworkImage(eventImageURL)),
        );

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
