// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offeredAchievements.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$offeredAchievementsSerializer
    implements Serializer<OfferedAchievents> {
  @override
  Map<String, dynamic> toMap(OfferedAchievents model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.achievementID);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'description', model.desc);
    setMapValue(ret, 'body', model.body);
    setMapValue(ret, 'event', model.event);
    return ret;
  }

  @override
  OfferedAchievents fromMap(Map map) {
    if (map == null) return null;
    final obj = OfferedAchievents();
    obj.achievementID = map['id'] as String;
    obj.title = map['title'] as String;
    obj.desc = map['description'] as String;
    obj.body = map['body'] as String;
    obj.event = map['event'] as String;
    return obj;
  }
}
