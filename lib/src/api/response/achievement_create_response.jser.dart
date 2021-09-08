// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_create_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AchievementCreateResponseSerializer
    implements Serializer<AchievementCreateResponse> {
  @override
  Map<String, dynamic> toMap(AchievementCreateResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'result', model.result);
    setMapValue(ret, 'AchID', model.achID);
    return ret;
  }

  @override
  AchievementCreateResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = AchievementCreateResponse();
    obj.result = map['result'] as String;
    obj.achID = map['AchID'] as String;
    return obj;
  }
}
