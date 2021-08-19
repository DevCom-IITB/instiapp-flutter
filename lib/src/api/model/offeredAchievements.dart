import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offeredAchievements.jser.dart';

class OfferedAchievents {
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
class OfferedAchievementsSerializer extends Serializer<OfferedAchievents>
    with _$offeredAchievementsSerializer {}
