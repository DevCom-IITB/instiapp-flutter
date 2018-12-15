// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$EventSerializer implements Serializer<Event> {
  Serializer<Venue> __venueSerializer;
  Serializer<Venue> get _venueSerializer =>
      __venueSerializer ??= new VenueSerializer();
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer =>
      __userSerializer ??= new UserSerializer();
  @override
  Map<String, dynamic> toMap(Event model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.eventID);
    setMapValue(ret, 'str_id', model.eventStrID);
    setMapValue(ret, 'name', model.eventName);
    setMapValue(ret, 'description', model.eventDescription);
    setMapValue(ret, 'image_url', model.eventImageURL);
    setMapValue(ret, 'start_time', model.eventStartTime);
    setMapValue(ret, 'end_time', model.eventEndTime);
    setMapValue(ret, 'all_day', model.allDayEvent);
    setMapValue(
        ret,
        'venues',
        codeIterable(
            model.eventVenues, (val) => _venueSerializer.toMap(val as Venue)));
    setMapValue(
        ret,
        'bodies',
        codeIterable(
            model.eventBodies, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(ret, 'interested_count', model.eventInterestedCount);
    setMapValue(ret, 'going_count', model.eventGoingCount);
    setMapValue(
        ret,
        'interested',
        codeIterable(model.eventInterested,
            (val) => _userSerializer.toMap(val as User)));
    setMapValue(
        ret,
        'going',
        codeIterable(
            model.eventGoing, (val) => _userSerializer.toMap(val as User)));
    setMapValue(ret, 'website_url', model.eventWebsiteURL);
    setMapValue(ret, 'user_ues', model.eventUserUes);
    return ret;
  }

  @override
  Event fromMap(Map map) {
    if (map == null) return null;
    final obj = new Event();
    obj.eventID = map['id'] as String;
    obj.eventStrID = map['str_id'] as String;
    obj.eventName = map['name'] as String;
    obj.eventDescription = map['description'] as String;
    obj.eventImageURL = map['image_url'] as String;
    obj.eventStartTime = map['start_time'] as String;
    obj.eventEndTime = map['end_time'] as String;
    obj.allDayEvent = map['all_day'] as bool;
    obj.eventVenues = codeIterable<Venue>(map['venues'] as Iterable,
        (val) => _venueSerializer.fromMap(val as Map));
    obj.eventBodies = codeIterable<Body>(map['bodies'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.eventInterestedCount = map['interested_count'] as int;
    obj.eventGoingCount = map['going_count'] as int;
    obj.eventInterested = codeIterable<User>(map['interested'] as Iterable,
        (val) => _userSerializer.fromMap(val as Map));
    obj.eventGoing = codeIterable<User>(
        map['going'] as Iterable, (val) => _userSerializer.fromMap(val as Map));
    obj.eventWebsiteURL = map['website_url'] as String;
    obj.eventUserUes = map['user_ues'] as int;
    return obj;
  }
}
