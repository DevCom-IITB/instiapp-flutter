import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offeredAchievements.g.dart';

class OfferedAchievements {
  @JsonKey("id")
  String achievementID;

  @JsonKey("title")
  String title;

  @JsonKey("description")
  String desc;

  @JsonKey("body")
  String body;

  @JsonKey("event")
  String event;

  @JsonKey("priority")
  int priority;

  @JsonKey("secret")
  String secret;

  @JsonKey("users")
  List<User> users;

  @JsonKey("stat")
  int stat;

  OfferedAchievements(
      {this.achievementID,
      this.title,
      this.desc,});
  
  factory OfferedAchievements.fromJson(Map<String, dynamic> json) =>
      _$OfferedAchievementsFromJson(json);

  Map<String, dynamic> toJson() => _$OfferedAchievementsToJson(this);
}

@GenSerializer()
class OfferedAchievementsSerializer extends Serializer<OfferedAchievements>
    with _$OfferedAchievementsSerializer {}
