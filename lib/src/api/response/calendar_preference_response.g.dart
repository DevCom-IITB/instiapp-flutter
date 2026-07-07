// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_preference_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarPreferencesResponse _$CalendarPreferencesResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarPreferencesResponse(
      showInstiappGoing: json['show_instiapp_going'] as bool?,
      showInstiappFollowedBodies:
          json['show_instiapp_followed_bodies'] as bool?,
      showResobin: json['show_resobin'] as bool?,
      notificationsEnabled: json['notifications_enabled'] as bool?,
    );

Map<String, dynamic> _$CalendarPreferencesResponseToJson(
        CalendarPreferencesResponse instance) =>
    <String, dynamic>{
      'show_instiapp_going': instance.showInstiappGoing,
      'show_instiapp_followed_bodies': instance.showInstiappFollowedBodies,
      'show_resobin': instance.showResobin,
      'notifications_enabled': instance.notificationsEnabled,
    };
