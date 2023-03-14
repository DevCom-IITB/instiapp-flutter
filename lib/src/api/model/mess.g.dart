// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hostel _$HostelFromJson(Map<String, dynamic> json) => Hostel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      shortName: json['short_name'] as String?,
      longName: json['long_name'] as String?,
      mess: (json['mess'] as List<dynamic>?)
          ?.map((e) => HostelMess.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HostelToJson(Hostel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'long_name': instance.longName,
      'mess': instance.mess,
    };

HostelMess _$HostelMessFromJson(Map<String, dynamic> json) => HostelMess(
      id: json['id'] as String?,
      breakfast: json['breakfast'] as String?,
      day: json['day'] as int?,
      lunch: json['lunch'] as String?,
      snacks: json['snacks'] as String?,
      dinner: json['dinner'] as String?,
      hostel: json['hostel'] as String?,
    );

Map<String, dynamic> _$HostelMessToJson(HostelMess instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'breakfast': instance.breakfast,
      'lunch': instance.lunch,
      'snacks': instance.snacks,
      'dinner': instance.dinner,
      'hostel': instance.hostel,
    };
