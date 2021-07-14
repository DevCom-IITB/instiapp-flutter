// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_feed_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$NewsFeedResponseSerializer
    implements Serializer<NewsFeedResponse> {
  Serializer<Event> __eventSerializer;
  Serializer<Event> get _eventSerializer =>
      __eventSerializer ??= EventSerializer();
  @override
  Map<String, dynamic> toMap(NewsFeedResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(
        ret,
        'data',
        codeIterable(
            model.events, (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(ret, 'count', model.count);
    return ret;
  }

  @override
  NewsFeedResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = NewsFeedResponse();
    obj.events = codeIterable<Event>(
        map['data'] as Iterable, (val) => _eventSerializer.fromMap(val as Map));
    obj.count = map['count'] as int;
    return obj;
  }
}
