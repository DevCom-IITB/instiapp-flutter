// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCreateRequest _$EventCreateRequestFromJson(Map<String, dynamic> json) =>
    EventCreateRequest(
      eventName: json['name'] as String?,
      eventDescription: json['description'] as String?,
      eventImageURL: json['image_url'] as String?,
      eventWebsiteURL: json['website_url'] as String?,
      eventStartTime: json['start_time'] as String?,
      eventEndTime: json['end_time'] as String?,
      allDayEvent: json['all_day'] as bool?,
      notify: json['notify'] as bool?,
      eventUserTags: (json['user_tags'] as List<dynamic>?)?.map((e) => e as int).toList(),
      eventVenueNames: (json['venue_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      eventBodiesID: (json['bodies_id'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      // eventUserTags: (json[''])
    );

Map<String, dynamic> _$EventCreateRequestToJson(EventCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.eventName,
      'description': instance.eventDescription,
      'image_url': instance.eventImageURL,
      'website_url':instance.eventWebsiteURL,
      'start_time': instance.eventStartTime,
      'end_time': instance.eventEndTime,
      'all_day': instance.allDayEvent,
      'venue_names': instance.eventVenueNames,
      'bodies_id': instance.eventBodiesID,
      'notify':instance.notify,
      'user_tags':instance.eventUserTags
    };
