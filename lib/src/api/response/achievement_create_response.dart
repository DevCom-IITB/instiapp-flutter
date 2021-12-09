import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'achievement_create_response.g.dart';

class AchievementCreateResponse {
  String result;
  String achID;

  AchievementCreateResponse({
    this.result,
    this.achID,
  });
  factory AchievementCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$AchievementCreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementCreateResponseToJson(this);
}

@GenSerializer()
class AchievementCreateResponseSerializer
    extends Serializer<AchievementCreateResponse>
    with _$AchievementCreateResponseSerializer {}
