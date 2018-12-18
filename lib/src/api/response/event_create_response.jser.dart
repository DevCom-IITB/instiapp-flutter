// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$EventCreateResponseSerializer
    implements Serializer<EventCreateResponse> {
  @override
  Map<String, dynamic> toMap(EventCreateResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'result', model.result);
    setMapValue(ret, 'eventId', model.eventId);
    return ret;
  }

  @override
  EventCreateResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new EventCreateResponse();
    obj.result = map['result'] as String;
    obj.eventId = map['eventId'] as String;
    return obj;
  }
}
