import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';

part 'achievement_create_request.jser.dart';


class AchievementCreateRequest {

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

  @Alias("body")
  String bodyID;

  @Alias("body_detail")
  Body body;

  @Alias("event_detail")
  Event event;

  @Alias("offer")
  String offer;

}

@GenSerializer()
class AchievementCreateRequestSerializer
    extends Serializer<AchievementCreateRequest>
    with _$AchievementCreateRequestSerializer {}
