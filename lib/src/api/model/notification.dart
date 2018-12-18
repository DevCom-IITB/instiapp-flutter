import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'notification.jser.dart';

class Notification {
  @Alias("id")
  int notificationId;

  @Alias("verb")
  String notificationVerb;

  @Alias("unread")
  bool notificationUnread;

  @Alias("actor_type")
  String notificationActorType;

  @Alias("actor")
  Object notificationActor;
}

@GenSerializer()
class NotificationSerializer extends Serializer<Notification> with _$NotificationSerializer {}