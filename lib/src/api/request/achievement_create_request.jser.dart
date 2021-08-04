// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_create_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$AchievementCreateRequestSerializer
    implements Serializer<AchievementCreateRequest> {
  Serializer<Event> __eventSerializer;
  Serializer<Event> get _eventSerializer =>
      __eventSerializer ??= EventSerializer();
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer => __bodySerializer ??= BodySerializer();
  @override
  Map<String, dynamic> toMap(AchievementCreateRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'description', model.description);
    setMapValue(ret, 'admin_note', model.admin_note);
    setMapValue(ret, 'event', _eventSerializer.toMap(model.event));
    setMapValue(ret, 'body', _bodySerializer.toMap(model.verauth));
    return ret;
  }

  @override
  AchievementCreateRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = AchievementCreateRequest();
    obj.title = map['title'] as String;
    obj.description = map['description'] as String;
    obj.admin_note = map['admin_note'] as String;
    obj.event = _eventSerializer.fromMap(map['event'] as Map);
    obj.verauth = _bodySerializer.fromMap(map['body'] as Map);
    return obj;
  }
}
