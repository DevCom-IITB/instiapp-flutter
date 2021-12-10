// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCreateResponse _$EventCreateResponseFromJson(Map<String, dynamic> json) =>
    EventCreateResponse(
      result: json['result'] as String?,
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$EventCreateResponseToJson(
        EventCreateResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'eventId': instance.eventId,
    };
