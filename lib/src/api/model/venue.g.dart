// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) => Venue(
      venueID: json['id'] as String?,
      venueName: json['name'] as String?,
      venueShortName: json['short_name'] as String?,
      venueDescripion: json['description'] as String?,
      venueParentId: json['parent'] as String?,
      venueParentRelation: json['parent_relation'] as String?,
      venueGroupId: json['group_id'] as int?,
      venuePixelX: json['pixel_x'] as int?,
      venuePixelY: json['pixel_y'] as int?,
      venueReusable: json['reusable'] as bool?,
      venueLatitude: json['lat'] as String?,
      venueLongitude: json['lng'] as String?,
    );

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.venueID,
      'name': instance.venueName,
      'short_name': instance.venueShortName,
      'description': instance.venueDescripion,
      'parent': instance.venueParentId,
      'parent_relation': instance.venueParentRelation,
      'group_id': instance.venueGroupId,
      'pixel_x': instance.venuePixelX,
      'pixel_y': instance.venuePixelY,
      'reusable': instance.venueReusable,
      'lat': instance.venueLatitude,
      'lng': instance.venueLongitude,
    };
