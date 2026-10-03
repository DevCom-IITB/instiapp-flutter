// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      notificationId: json['id'] as int?,
      notificationVerb: json['verb'] as String?,
      notificationUnread: json['unread'] as bool?,
      notificationActorType: json['actor_type'] as String?,
      notificationActor: json['actor'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.notificationId,
      'verb': instance.notificationVerb,
      'unread': instance.notificationUnread,
      'actor_type': instance.notificationActorType,
      'actor': instance.notificationActor,
    };
