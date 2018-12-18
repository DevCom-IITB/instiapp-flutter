// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ExploreResponseSerializer
    implements Serializer<ExploreResponse> {
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
  Serializer<Event> __eventSerializer;
  Serializer<Event> get _eventSerializer =>
      __eventSerializer ??= new EventSerializer();
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer =>
      __userSerializer ??= new UserSerializer();
  @override
  Map<String, dynamic> toMap(ExploreResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(
        ret,
        'bodies',
        codeIterable(
            model.bodies, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(
        ret,
        'events',
        codeIterable(
            model.events, (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(ret, 'users',
        codeIterable(model.users, (val) => _userSerializer.toMap(val as User)));
    return ret;
  }

  @override
  ExploreResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new ExploreResponse();
    obj.bodies = codeIterable<Body>(map['bodies'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.events = codeIterable<Event>(map['events'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.users = codeIterable<User>(
        map['users'] as Iterable, (val) => _userSerializer.fromMap(val as Map));
    return obj;
  }
}
