// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_hidden_patch_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AchievementHiddenPathRequestSerializer
    implements Serializer<AchievementHiddenPathRequest> {
  @override
  Map<String, dynamic> toMap(AchievementHiddenPathRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'hidden', model.hidden);
    return ret;
  }

  @override
  AchievementHiddenPathRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = AchievementHiddenPathRequest();
    obj.hidden = map['hidden'] as bool;
    return obj;
  }
}
