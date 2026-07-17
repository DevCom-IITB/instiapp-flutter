import 'package:json_annotation/json_annotation.dart';

part 'popup_notification_response.g.dart';

@JsonSerializable()
class PopupNotificationResponse {
  int? id;

  String? heading;

  @JsonKey(name: "short_description")
  String? shortDescription;

  @JsonKey(name: "long_description")
  String? longDescription;

  @JsonKey(name: "image_url")
  String? imageUrl;

  List<dynamic>? links;

  @JsonKey(name: "is_active")
  bool? isActive;

  @JsonKey(name: "created_at")
  String? createdAt;

  @JsonKey(name: "updated_at")
  String? updatedAt;

  PopupNotificationResponse({
    this.id,
    this.heading,
    this.shortDescription,
    this.longDescription,
    this.imageUrl,
    this.links,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PopupNotificationResponse.fromJson(
      Map<String, dynamic> json) =>
      _$PopupNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PopupNotificationResponseToJson(this);
}