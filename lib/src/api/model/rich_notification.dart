import 'package:json_annotation/json_annotation.dart';

part 'rich_notification.g.dart';

@JsonSerializable()
class RichNotification {
  @JsonKey(name: "type")
  String? notificationType;
  @JsonKey(name: "id")
  String? notificationObjectID;
  @JsonKey(name: "extra")
  String? notificationExtra;
  @JsonKey(name: "notification_id")
  String? notificationID;
  @JsonKey(name: "title")
  String? notificationTitle;
  @JsonKey(name: "verb")
  String? notificationVerb;
  @JsonKey(name:"large_icon")
  String? notificationLargeIcon;
  @JsonKey(name: "large_content")
  String? notificationLargeContent;
  @JsonKey(name: "image_url")
  String? notificationImage;

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
