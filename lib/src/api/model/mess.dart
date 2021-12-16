import 'package:json_annotation/json_annotation.dart';
import 'dart:core';
part 'mess.g.dart';

@JsonSerializable()
class Hostel {
  String? id;
  String? name;

  @JsonKey(name: 'short_name')
  String? shortName;

  @JsonKey(name: 'long_name')
  String? longName;

  @JsonKey(name: 'mess')
  List<HostelMess>? mess;

  int compareTo(Hostel h) {
    int? x = int.tryParse(this.shortName!);
    if (x == null) {
      return this.shortName!.compareTo(h.shortName!);
    }
    int? y = int.tryParse(h.shortName!);
    if (y == null) {
      return this.shortName!.compareTo(h.shortName!);
    }
    return x.compareTo(y);
  }

  Hostel({this.id, this.name, this.shortName, this.longName, this.mess});

  factory Hostel.fromJson(Map<String, dynamic> json) => _$HostelFromJson(json);

  Map<String, dynamic> toJson() => _$HostelToJson(this);
}

@JsonSerializable()
class HostelMess {
  String? id;
  int? day;
  String? breakfast;
  String? lunch;
  String? snacks;
  String? dinner;
  String? hostel;

  int compareTo(HostelMess h) {
    final now = DateTime.now();
    int today = now.weekday;

    int x = (this.day! - today) + (this.day! - today < 0 ? 7 : 0);
    int y = (h.day! - today) + (h.day! - today < 0 ? 7 : 0);

    return x.compareTo(y);
  }

  static Map<int, String> dayToName = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  HostelMess({
    this.id,
    this.breakfast,
    this.day,
    this.lunch,
    this.snacks,
    this.dinner,
    this.hostel
  });

  factory HostelMess.fromJson(Map<String, dynamic> json) => _$HostelMessFromJson(json);

  Map<String, dynamic> toJson() => _$HostelMessToJson(this);

  getDayName() => dayToName[this.day];
}
