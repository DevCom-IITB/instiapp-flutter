// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_pref_body_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarPrefBodyResponse _$CalendarPrefBodyResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarPrefBodyResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map(
              (e) => CalendarBodyPreference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalendarPrefBodyResponseToJson(
        CalendarPrefBodyResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
