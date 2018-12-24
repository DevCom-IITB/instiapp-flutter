// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$BodySerializer implements Serializer<Body> {
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
  Serializer<Event> __eventSerializer;
  Serializer<Event> get _eventSerializer =>
      __eventSerializer ??= new EventSerializer();
  Serializer<Role> __roleSerializer;
  Serializer<Role> get _roleSerializer =>
      __roleSerializer ??= new RoleSerializer();
  @override
  Map<String, dynamic> toMap(Body model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.bodyID);
    setMapValue(ret, 'str_id', model.bodyStrID);
    setMapValue(ret, 'name', model.bodyName);
    setMapValue(ret, 'short_description', model.bodyShortDescription);
    setMapValue(ret, 'description', model.bodyDescription);
    setMapValue(ret, 'image_url', model.bodyImageURL);
    setMapValue(
        ret,
        'children',
        codeIterable(
            model.bodyChildren, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(
        ret,
        'parents',
        codeIterable(
            model.bodyParents, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(
        ret,
        'events',
        codeIterable(
            model.bodyEvents, (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(ret, 'followers_count', model.bodyFollowersCount);
    setMapValue(ret, 'website_url', model.bodyWebsiteURL);
    setMapValue(ret, 'blog_url', model.bodyBlogURL);
    setMapValue(ret, 'user_follows', model.bodyUserFollows);
    setMapValue(
        ret,
        'roles',
        codeIterable(
            model.bodyRoles, (val) => _roleSerializer.toMap(val as Role)));
    return ret;
  }

  @override
  Body fromMap(Map map) {
    if (map == null) return null;
    final obj = new Body();
    obj.bodyID = map['id'] as String;
    obj.bodyStrID = map['str_id'] as String;
    obj.bodyName = map['name'] as String;
    obj.bodyShortDescription = map['short_description'] as String;
    obj.bodyDescription = map['description'] as String;
    obj.bodyImageURL = map['image_url'] as String;
    obj.bodyChildren = codeIterable<Body>(map['children'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.bodyParents = codeIterable<Body>(map['parents'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.bodyEvents = codeIterable<Event>(map['events'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.bodyFollowersCount = map['followers_count'] as int;
    obj.bodyWebsiteURL = map['website_url'] as String;
    obj.bodyBlogURL = map['blog_url'] as String;
    obj.bodyUserFollows = map['user_follows'] as bool;
    obj.bodyRoles = codeIterable<Role>(
        map['roles'] as Iterable, (val) => _roleSerializer.fromMap(val as Map));
    return obj;
  }
}
