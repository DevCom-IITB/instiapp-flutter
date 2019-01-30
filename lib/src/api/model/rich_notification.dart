import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'rich_notification.jser.dart';

class RichNotification {
  @Alias("type")
  String notificationType;
  @Alias("id")
  String notificationObjectID;
  @Alias("extra")
  String notificationExtra;
  @Alias("notification_id")
  String notificationID;
  @Alias("title")
  String notificationTitle;
  @Alias("verb")
  String notificationVerb;
  @Alias("large_icon")
  String notificationLargeIcon;
  @Alias("large_content")
  String notificationLargeContent;
  @Alias("image_url")
  String notificationImage;
}


@GenSerializer()
class RichNotificationSerializer extends Serializer<RichNotification> with _$RichNotificationSerializer {}