// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarBody _$CalendarBodyFromJson(Map<String, dynamic> json) => CalendarBody(
      id: json['body_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      isPublic: json['is_public'] as bool?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CalendarBodyToJson(CalendarBody instance) =>
    <String, dynamic>{
      'body_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'color': instance.color,
      'is_public': instance.isPublic,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
