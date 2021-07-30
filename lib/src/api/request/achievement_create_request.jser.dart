// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_create_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AchievementCreateRequestSerializer
    implements Serializer<AchievementCreateRequest> {
  @override
  Map<String, dynamic> toMap(AchievementCreateRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'description', model.description);
    setMapValue(ret, 'admin_note', model.adminNote);
    setMapValue(ret, 'body', model.body);
    setMapValue(ret, 'event', model.event);
    setMapValue(ret, 'verified_by', model.verauth);
    return ret;
  }

  @override
  AchievementCreateRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = AchievementCreateRequest();
    obj.title = map['title'] as String;
    obj.description = map['description'] as String;
    obj.adminNote = map['admin_note'] as String;
    obj.body = map['body'] as String;
    obj.event = map['event'] as String;
    obj.verauth = map['verified_by'] as String;
    return obj;
  }
}
