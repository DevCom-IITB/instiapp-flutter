// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarItem _$CalendarItemFromJson(Map<String, dynamic> json) => CalendarItem(
      uid: json['uid'] as String,
      title: json['title'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      all_day: json['all_day'] as bool,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$CalendarItemToJson(CalendarItem instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'all_day': instance.all_day,
      'location': instance.location,
    };
