import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'achievement_create_response.jser.dart';

class AchievementCreateResponse {
  String result;
  String achID;
}

@GenSerializer()
class AchievementCreateResponseSerializer
    extends Serializer<AchievementCreateResponse>
    with _$AchievementCreateResponseSerializer {}
