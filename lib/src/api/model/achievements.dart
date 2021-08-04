import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';

part 'achievements.jser.dart';

class Achievement {
  @Alias("id")
  String id;

  @Alias("time_of_creation")
  String timeOfCreation;

  @Alias("time_of_modification")
  String timeOfModification;

  @Alias("user")
  User user;

  @Alias("hidden")
  bool hidden;

  @Alias("dismissed")
  bool dismissed;

  @Alias("verified")
  bool verified;

  @Alias("verified_by")
  User verifiedBy;

  @Alias("title")
  String title;

  @Alias("description")
  String description;

  @Alias("admin_note")
  String adminNote;

  @Alias("body_detail")
  Body body;

  @Alias("event_detail")
  Event event;

  //TODO: Make string an offered achievement
  @Alias("offer")
  String offer;
}

@GenSerializer()
class AchievementSerializer extends Serializer<Achievement>
    with _$AchievementSerializer {}
