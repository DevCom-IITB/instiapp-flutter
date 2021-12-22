import 'package:json_annotation/json_annotation.dart';

part 'achievement_hidden_patch_request.g.dart';

@JsonSerializable()
class AchievementHiddenPathRequest {
  @JsonKey(name: "hidden")
  bool? hidden;

  AchievementHiddenPathRequest({this.hidden});
  factory AchievementHiddenPathRequest.fromJson(Map<String, dynamic> json) =>
      _$AchievementHiddenPathRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementHiddenPathRequestToJson(this);
}
