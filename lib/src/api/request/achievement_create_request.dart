import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';

part 'achievement_create_request.g.dart';

@JsonSerializable()
class AchievementCreateRequest {
@JsonKey(name: "id")
  String? id;

  @JsonKey(name: "time_of_creation")
  String? timeOfCreation;

  @JsonKey(name: "time_of_modification")
  String? timeOfModification;

  @JsonKey(name: "user")
  User? user;

  @JsonKey(name: "hidden")
  bool? hidden;

  @JsonKey(name: "dismissed")
  bool? dismissed;

  @JsonKey(name: "verified")
  bool? verified;

  @JsonKey(name: "verified_by")
  User? verifiedBy;

  @JsonKey(name: "title")
  String? title;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "admin_note")
  String? adminNote;

  @JsonKey(name: "body")
  String? bodyID;

  @JsonKey(name: "body_detail")
  Body? body;

  @JsonKey(name: "event_detail")
  Event? event;

  @JsonKey(name: "offer")
  String? offer;

  @JsonKey(name: "isSkill")
  bool? isSkill;

  AchievementCreateRequest({
      this.id,
      this.timeOfCreation,
      this.timeOfModification,
      this.user,
      this.hidden,
      this.dismissed,
      this.verified,
      this.verifiedBy,
      this.title,
      this.description,
      this.adminNote,
      this.bodyID,
      this.body,
      this.event,
      this.offer,
  this.isSkill});
  factory AchievementCreateRequest.fromJson(Map<String, dynamic> json) => _$AchievementCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementCreateRequestToJson(this);

}
