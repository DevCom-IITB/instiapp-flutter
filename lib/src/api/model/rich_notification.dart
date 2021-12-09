import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'rich_notification.g.dart';

class RichNotification {
  @JsonKey("type")
  String notificationType;
  @JsonKey("id")
  String notificationObjectID;
  @JsonKey("extra")
  String notificationExtra;
  @JsonKey("notification_id")
  String notificationID;
  @JsonKey("title")
  String notificationTitle;
  @JsonKey("verb")
  String notificationVerb;
  @JsonKey("large_icon")
  String notificationLargeIcon;
  @JsonKey("large_content")
  String notificationLargeContent;
  @JsonKey("image_url")
  String notificationImage;

  RichNotification(
      {this.notificationType,
      this.notificationObjectID,
      this.notificationExtra,
      this.notificationID,
      this.notificationTitle,
      this.notificationVerb,
      this.notificationLargeIcon,
      this.notificationLargeContent,
      this.notificationImage});
  factory RichNotification.fromJson(Map<String, dynamic> json) =>
      _$RichNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$RichNotificationToJson(this);
}

@GenSerializer()
class RichNotificationSerializer extends Serializer<RichNotification>
    with _$RichNotificationSerializer {}
