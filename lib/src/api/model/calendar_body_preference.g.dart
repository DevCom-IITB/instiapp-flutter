// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_body_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarBodyPreference _$CalendarBodyPreferenceFromJson(
        Map<String, dynamic> json) =>
    CalendarBodyPreference(
      bodyId: json['body_id'] as String?,
      bodyName: json['body_name'] as String?,
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$CalendarBodyPreferenceToJson(
        CalendarBodyPreference instance) =>
    <String, dynamic>{
      'body_id': instance.bodyId,
      'body_name': instance.bodyName,
      'enabled': instance.enabled,
    };
