// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'your_achievements_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$YourAchievementsResponseSerializer
    implements Serializer<YourAchievementsResponse> {
  Serializer<Achievement> __achievementSerializer;
  Serializer<Achievement> get _achievementSerializer =>
      __achievementSerializer ??= AchievementSerializer();
  @override
  Map<String, dynamic> toMap(YourAchievementsResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(
        ret,
        'data',
        codeIterable(model.achievements,
            (val) => _achievementSerializer.toMap(val as Achievement)));
    return ret;
  }

  @override
  YourAchievementsResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = YourAchievementsResponse();
    obj.achievements = codeIterable<Achievement>(map['data'] as Iterable,
        (val) => _achievementSerializer.fromMap(val as Map));
    return obj;
  }
}
