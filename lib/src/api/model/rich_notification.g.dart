// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rich_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RichNotification _$RichNotificationFromJson(Map<String, dynamic> json) =>
    RichNotification(
      notificationType: json['type'] as String?,
      notificationObjectID: json['id'] as String?,
      notificationExtra: json['name: extra'] as String?,
      notificationID: json['notification_id'] as String?,
      notificationTitle: json['title'] as String?,
      notificationVerb: json['verb'] as String?,
      notificationLargeIcon: json['large_icon'] as String?,
      notificationLargeContent: json['large_content'] as String?,
      notificationImage: json['image_url'] as String?,
    );

Map<String, dynamic> _$RichNotificationToJson(RichNotification instance) =>
    <String, dynamic>{
      'type': instance.notificationType,
      'id': instance.notificationObjectID,
      'name: extra': instance.notificationExtra,
      'notification_id': instance.notificationID,
      'title': instance.notificationTitle,
      'verb': instance.notificationVerb,
      'large_icon': instance.notificationLargeIcon,
      'large_content': instance.notificationLargeContent,
      'image_url': instance.notificationImage,
    };
