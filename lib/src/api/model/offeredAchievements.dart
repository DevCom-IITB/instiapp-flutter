import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'offeredAchievements.g.dart';

@JsonSerializable()
class OfferedAchievements {
  @JsonKey(name: "id")
  String? achievementID;

  @JsonKey(name: "title")
  String? title;

  @JsonKey(name: "description")
  String? desc;

  @JsonKey(name: "body")
  String? body;

  @JsonKey(name: "event")
  String? event;

  @JsonKey(name: "priority")
  int? priority;

  @JsonKey(name: "secret")
  String? secret;

  @JsonKey(name: "generic")
  String? generic;

  @JsonKey(name: "users")
  List<User>? users;

  @JsonKey(name: "stat")
  int? stat;

  OfferedAchievements(
      {this.achievementID,
      this.title,
      this.desc,
      this.body,
      this.event,
      this.priority,
      this.secret,
      this.stat,
      this.users,
      this.generic
      });
  
  factory OfferedAchievements.fromJson(Map<String, dynamic> json) =>
      _$OfferedAchievementsFromJson(json);

  Map<String, dynamic> toJson() => _$OfferedAchievementsToJson(this);
}
