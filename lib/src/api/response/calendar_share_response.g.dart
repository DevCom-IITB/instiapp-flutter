// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_share_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarShareResponse _$CalendarShareResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarShareResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CalendarBody.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalendarShareResponseToJson(
        CalendarShareResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
