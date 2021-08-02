import 'package:jaguar_serializer/jaguar_serializer.dart';
part 'achievement_create_request.jser.dart';


class AchievementCreateRequest {

  @Alias("title")
  String title;

  @Alias("description")
  String description;

  @Alias("admin_note")
  String adminNote;

  @Alias("body")
  String body;

  @Alias("event")
  String event;

  @Alias("verified_by")
  String verauth;
}

@GenSerializer()
class AchievementCreateRequestSerializer
    extends Serializer<AchievementCreateRequest>
    with _$AchievementCreateRequestSerializer {}
