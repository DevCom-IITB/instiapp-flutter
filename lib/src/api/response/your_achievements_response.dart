import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'your_achievements_response.g.dart';

class YourAchievementsResponse {
  @JsonKey("data")
  List<Achievement> achievements;

  YourAchievementsResponse(this.achievements);
  factory YourAchievementsResponse.fromJson(Map<String, dynamic> json) =>
      _$YourAchievementsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YourAchievementsResponseToJson(this); 
}

@GenSerializer()
class YourAchievementsResponseSerializer
    extends Serializer<YourAchievementsResponse>
    with _$YourAchievementsResponseSerializer {}
