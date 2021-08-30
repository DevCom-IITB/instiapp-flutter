import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offeredAchievements.jser.dart';

class offeredAchievements {
  @Alias("id")
  String achievementID;

  @Alias("title")
  String title;

  @Alias("description")
  String desc;

  @Alias("body")
  String body;

  @Alias("event")
  String event;

  @Alias("priority")
  int priority;

  @Alias("secret")
  String secret;

  @Alias("users")
  List<User> users;

  @Alias("stat")
  int stat;
}

@GenSerializer()
class OfferedAchievementsSerializer extends Serializer<offeredAchievements>
    with _$offeredAchievementsSerializer {}
