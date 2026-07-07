// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarInfoResponse _$CalendarInfoResponseFromJson(
        Map<String, dynamic> json) =>
    CalendarInfoResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      isPublic: json['is_public'] as bool?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: (json['upcoming_events'] as List<dynamic>?)
          ?.map((e) => CalendarBody.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalendarInfoResponseToJson(
        CalendarInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'color': instance.color,
      'is_public': instance.isPublic,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'upcoming_events': instance.items,
    };
