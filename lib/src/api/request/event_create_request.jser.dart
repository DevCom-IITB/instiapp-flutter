// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$EventCreateRequestSerializer
    implements Serializer<EventCreateRequest> {
  @override
  Map<String, dynamic> toMap(EventCreateRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'name', model.eventName);
    setMapValue(ret, 'description', model.eventDescription);
    setMapValue(ret, 'image_url', model.eventImageURL);
    setMapValue(ret, 'start_time', model.eventStartTime);
    setMapValue(ret, 'end_time', model.eventEndTime);
    setMapValue(ret, 'all_day', model.allDayEvent);
    setMapValue(ret, 'venue_names',
        codeIterable(model.eventVenueNames, (val) => val as String));
    setMapValue(ret, 'bodies_id',
        codeIterable(model.eventBodiesID, (val) => val as String));
    return ret;
  }

  @override
  EventCreateRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = new EventCreateRequest();
    obj.eventName = map['name'] as String;
    obj.eventDescription = map['description'] as String;
    obj.eventImageURL = map['image_url'] as String;
    obj.eventStartTime = map['start_time'] as String;
    obj.eventEndTime = map['end_time'] as String;
    obj.allDayEvent = map['all_day'] as bool;
    obj.eventVenueNames = codeIterable<String>(
        map['venue_names'] as Iterable, (val) => val as String);
    obj.eventBodiesID = codeIterable<String>(
        map['bodies_id'] as Iterable, (val) => val as String);
    return obj;
  }
}
