import 'package:json_annotation/json_annotation.dart';

part 'achievement_create_response.g.dart';

@JsonSerializable()
class AchievementCreateResponse {
  String? result;
  String? achID;

  AchievementCreateResponse({
    this.result,
    this.achID,
  });
  factory AchievementCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$AchievementCreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementCreateResponseToJson(this);
}
