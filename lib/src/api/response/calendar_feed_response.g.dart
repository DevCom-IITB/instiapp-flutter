// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarFeedResponse _$CalendarFeedResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarFeedResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalendarFeedResponseToJson(
        CalendarFeedResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
