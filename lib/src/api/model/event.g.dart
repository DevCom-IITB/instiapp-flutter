// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      eventID: json['id'] as String?,
      eventStrID: json['str_id'] as String?,
      eventName: json['name'] as String?,
      verificationBodies: (json['verification_bodies'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventDescription: json['description'] as String?,
      eventImageURL: json['image_url'] as String?,
      eventStartTime: json['start_time'] as String?,
      eventEndTime: json['end_time'] as String?,
      allDayEvent: json['all_day'] as bool?,
      eventVenues: (json['venues'] as List<dynamic>?)
          ?.map((e) => Venue.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventBodies: (json['bodies'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventOfferedAchievements: (json['offered_achievements'] as List<dynamic>?)
          ?.map((e) => OfferedAchievements.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventInterestedCount: (json['interested_count'] as num?)?.toInt() ?? 0,
      eventGoingCount: (json['going_count'] as num?)?.toInt() ?? 0,
      eventUserTags: (json['user_tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      eventInterested: (json['interested'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventGoing: (json['going'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventWebsiteURL: json['website_url'] as String?,
      eventUserUesInt: (json['user_ues'] as num?)?.toInt(),
      eventInterest: (json['event_interest'] as List<dynamic>?)
          ?.map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..eventLongDescription = json['longdescription'] as String?
      ..emailVerified = json['email_verified'] as bool?
      ..eventStartDate = json['eventStartDate'] == null
          ? null
          : DateTime.parse(json['eventStartDate'] as String);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.eventID,
      'str_id': instance.eventStrID,
      'name': instance.eventName,
      'description': instance.eventDescription,
      'verification_bodies': instance.verificationBodies,
      'longdescription': instance.eventLongDescription,
      'image_url': instance.eventImageURL,
      'start_time': instance.eventStartTime,
      'end_time': instance.eventEndTime,
      'all_day': instance.allDayEvent,
      'email_verified': instance.emailVerified,
      'venues': instance.eventVenues,
      'bodies': instance.eventBodies,
      'offered_achievements': instance.eventOfferedAchievements,
      'interested_count': instance.eventInterestedCount,
      'going_count': instance.eventGoingCount,
      'interested': instance.eventInterested,
      'going': instance.eventGoing,
      'website_url': instance.eventWebsiteURL,
      'user_ues': instance.eventUserUesInt,
      'user_tags': instance.eventUserTags,
      'event_interest': instance.eventInterest,
      'eventStartDate': instance.eventStartDate?.toIso8601String(),
    };
