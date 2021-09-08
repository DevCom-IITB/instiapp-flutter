import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'your_achievements_response.jser.dart';

class YourAchievementsResponse {
  @Alias("data")
  List<Achievement> achievements;
}

@GenSerializer()
class YourAchievementsResponseSerializer
    extends Serializer<YourAchievementsResponse>
    with _$YourAchievementsResponseSerializer {}
