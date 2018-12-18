// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$NotificationSerializer implements Serializer<Notification> {
  @override
  Map<String, dynamic> toMap(Notification model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.notificationId);
    setMapValue(ret, 'verb', model.notificationVerb);
    setMapValue(ret, 'unread', model.notificationUnread);
    setMapValue(ret, 'actor_type', model.notificationActorType);
    setMapValue(ret, 'actor', passProcessor.serialize(model.notificationActor));
    return ret;
  }

  @override
  Notification fromMap(Map map) {
    if (map == null) return null;
    final obj = new Notification();
    obj.notificationId = map['id'] as int;
    obj.notificationVerb = map['verb'] as String;
    obj.notificationUnread = map['unread'] as bool;
    obj.notificationActorType = map['actor_type'] as String;
    obj.notificationActor = passProcessor.deserialize(map['actor']) as Object;
    return obj;
  }
}
