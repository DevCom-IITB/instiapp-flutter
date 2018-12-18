// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$VenueSerializer implements Serializer<Venue> {
  @override
  Map<String, dynamic> toMap(Venue model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.venueID);
    setMapValue(ret, 'name', model.venueName);
    setMapValue(ret, 'short_name', model.venueShortName);
    setMapValue(ret, 'description', model.venueDescripion);
    setMapValue(ret, 'parent', model.venueParentId);
    setMapValue(ret, 'parent_relation', model.venueParentRelation);
    setMapValue(ret, 'group_id', model.venueGroupId);
    setMapValue(ret, 'pixel_x', model.venuePixelX);
    setMapValue(ret, 'pixel_y', model.venuePixelY);
    setMapValue(ret, 'reusable', model.venueReusable);
    setMapValue(ret, 'lat', model.venueLatitude);
    setMapValue(ret, 'lng', model.venueLongitude);
    return ret;
  }

  @override
  Venue fromMap(Map map) {
    if (map == null) return null;
    final obj = new Venue();
    obj.venueID = map['id'] as String;
    obj.venueName = map['name'] as String;
    obj.venueShortName = map['short_name'] as String;
    obj.venueDescripion = map['description'] as String;
    obj.venueParentId = map['parent'] as String;
    obj.venueParentRelation = map['parent_relation'] as String;
    obj.venueGroupId = map['group_id'] as int;
    obj.venuePixelX = map['pixel_x'] as int;
    obj.venuePixelY = map['pixel_y'] as int;
    obj.venueReusable = map['reusable'] as bool;
    obj.venueLatitude = map['lat'] as String;
    obj.venueLongitude = map['lng'] as String;
    return obj;
  }
}
