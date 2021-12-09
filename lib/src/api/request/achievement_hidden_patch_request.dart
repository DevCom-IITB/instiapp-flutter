import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'achievement_hidden_patch_request.g.dart';

class AchievementHiddenPathRequest {
  @JsonKey("hidden")
  bool hidden;

  AchievementHiddenPathRequest({this.hidden});
  factory AchievementHiddenPathRequest.fromJson(Map<String, dynamic> json) =
      _$AchievementHiddenPathRequestFromJson;
  Map<String, dynamic> toJson() => _$AchievementHiddenPathRequestToJson(this);
}

@GenSerializer()
class AchievementHiddenPathRequestSerializer
    extends Serializer<AchievementHiddenPathRequest>
    with _$AchievementHiddenPathRequestSerializer {}
