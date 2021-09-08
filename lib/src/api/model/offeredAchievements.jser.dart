// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offeredAchievements.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$OfferedAchievementsSerializer
    implements Serializer<OfferedAchievements> {
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer => __userSerializer ??= UserSerializer();
  @override
  Map<String, dynamic> toMap(OfferedAchievements model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.achievementID);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'description', model.desc);
    setMapValue(ret, 'body', model.body);
    setMapValue(ret, 'event', model.event);
    setMapValue(ret, 'priority', model.priority);
    setMapValue(ret, 'secret', model.secret);
    setMapValue(ret, 'users',
        codeIterable(model.users, (val) => _userSerializer.toMap(val as User)));
    setMapValue(ret, 'stat', model.stat);
    return ret;
  }

  @override
  OfferedAchievements fromMap(Map map) {
    if (map == null) return null;
    final obj = OfferedAchievements();
    obj.achievementID = map['id'] as String;
    obj.title = map['title'] as String;
    obj.desc = map['description'] as String;
    obj.body = map['body'] as String;
    obj.event = map['event'] as String;
    obj.priority = map['priority'] as int;
    obj.secret = map['secret'] as String;
    obj.users = codeIterable<User>(
        map['users'] as Iterable, (val) => _userSerializer.fromMap(val as Map));
    obj.stat = map['stat'] as int;
    return obj;
  }
}
