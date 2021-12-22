import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:json_annotation/json_annotation.dart';

part 'your_achievements_response.g.dart';

@JsonSerializable()
class YourAchievementsResponse {
  @JsonKey(name: "data")
  List<Achievement>? achievements;

  YourAchievementsResponse(this.achievements);
  factory YourAchievementsResponse.fromJson(Map<String, dynamic> json) =>
      _$YourAchievementsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$YourAchievementsResponseToJson(this); 
}
