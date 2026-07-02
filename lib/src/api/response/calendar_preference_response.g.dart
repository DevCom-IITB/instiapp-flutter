// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_preference_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarPreferencesResponse _$CalendarPreferencesResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarPreferencesResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalendarPreferencesResponseToJson(
        CalendarPreferencesResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
