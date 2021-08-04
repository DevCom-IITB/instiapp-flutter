import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';

part 'achievement_create_request.jser.dart';


class AchievementCreateRequest {

  @Alias("title")
  String title;

  @Alias("description")
  String description;

  @Alias("admin_note")
  String admin_note;

  @Alias("event")
  Event event;

  @Alias("body")
  Body verauth;

}

@GenSerializer()
class AchievementCreateRequestSerializer
    extends Serializer<AchievementCreateRequest>
    with _$AchievementCreateRequestSerializer {}
