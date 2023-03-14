import 'package:flutter_calendar_carousel/classes/event.dart' as elt;

import 'package:json_annotation/json_annotation.dart';

part 'messCalEvent.g.dart';

// UserEventStatus
enum UES {
  NotGoing,
  Interested,
  Going,
}

@JsonSerializable()
class MessCalEvent extends elt.Event {
  @JsonKey(name: "id")
  String? eid;

  @JsonKey(name: "title")
  String? title;

  @JsonKey(name: "datetime")
  String? dateTime;

  @JsonKey(name: "hostel")
  int? hostel;

  DateTime? eventStartDate;

  MessCalEvent({this.eid, this.title, this.dateTime, this.hostel})
      : super(
          date: DateTime.parse(dateTime ?? ""),
          title: title,
        );

  factory MessCalEvent.fromJson(Map<String, dynamic> json) =>
      _$MessCalEventFromJson(json);

  Map<String, dynamic> toJson() => _$MessCalEventToJson(this);
}
