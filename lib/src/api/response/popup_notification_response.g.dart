// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popup_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PopupNotificationResponse _$PopupNotificationResponseFromJson(
        Map<String, dynamic> json) =>
    PopupNotificationResponse(
      id: (json['id'] as num?)?.toInt(),
      heading: json['heading'] as String?,
      shortDescription: json['short_description'] as String?,
      longDescription: json['long_description'] as String?,
      imageUrl: json['image_url'] as String?,
      links: json['links'] as List<dynamic>?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$PopupNotificationResponseToJson(
        PopupNotificationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'heading': instance.heading,
      'short_description': instance.shortDescription,
      'long_description': instance.longDescription,
      'image_url': instance.imageUrl,
      'links': instance.links,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
