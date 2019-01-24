// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rich_notification.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$RichNotificationSerializer
    implements Serializer<RichNotification> {
  @override
  Map<String, dynamic> toMap(RichNotification model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'type', model.notificationType);
    setMapValue(ret, 'id', model.notificationID);
    setMapValue(ret, 'extra', model.notificationExtra);
    setMapValue(ret, 'notification_id', model.notificationTypeID);
    setMapValue(ret, 'title', model.notificationTitle);
    setMapValue(ret, 'verb', model.notificationVerb);
    setMapValue(ret, 'large_icon', model.notificationLargeIcon);
    setMapValue(ret, 'large_content', model.notificationLargeContent);
    setMapValue(ret, 'image_url', model.notificationImage);
    return ret;
  }

  @override
  RichNotification fromMap(Map map) {
    if (map == null) return null;
    final obj = new RichNotification();
    obj.notificationType = map['type'] as String;
    obj.notificationID = map['id'] as String;
    obj.notificationExtra = map['extra'] as String;
    obj.notificationTypeID = map['notification_id'] as String;
    obj.notificationTitle = map['title'] as String;
    obj.notificationVerb = map['verb'] as String;
    obj.notificationLargeIcon = map['large_icon'] as String;
    obj.notificationLargeContent = map['large_content'] as String;
    obj.notificationImage = map['image_url'] as String;
    return obj;
  }
}
