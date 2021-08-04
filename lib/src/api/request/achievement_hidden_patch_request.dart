import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'achievement_hidden_patch_request.jser.dart';

class AchievementHiddenPathRequest {
  @Alias("hidden")
  bool hidden;
}

@GenSerializer()
class AchievementHiddenPathRequestSerializer
    extends Serializer<AchievementHiddenPathRequest>
    with _$AchievementHiddenPathRequestSerializer {}
