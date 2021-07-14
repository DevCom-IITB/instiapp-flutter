import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
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


}

@GenSerializer()
class offeredAchievementsSerializer extends Serializer<offeredAchievements> with _$offeredAchievementsSerializer {}

