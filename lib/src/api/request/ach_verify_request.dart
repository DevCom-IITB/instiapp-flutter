import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/body.dart';

part 'ach_verify_request.g.dart';

class AchVerifyRequest {
  @JsonKey("id")
  String id;

  @JsonKey("time_of_creation")
  String timeOfCreation;

  @JsonKey("time_of_modification")
  String timeOfModification;

  @JsonKey("user")
  User user;

  @JsonKey("hidden")
  bool hidden;

  @JsonKey("dismissed")
  bool dismissed;

  @JsonKey("verified")
  bool verified;

  @JsonKey("verified_by")
  User verifiedBy;

  @JsonKey("title")
  String title;

  @JsonKey("description")
  String description;

  @JsonKey("admin_note")
  String adminNote;

  @JsonKey("body")
  String bodyID;

  @JsonKey("body_detail")
  Body body;

  @JsonKey("event_detail")
  Event event;

  @JsonKey("offer")
  String offer;

  AchVerifyRequest(
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
      this.offer);
  factory AchVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$AchVerifyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AchVerifyRequestToJson(this);
}

@GenSerializer()
class AchVerifyRequestSerializer extends Serializer<AchVerifyRequest>
    with _$AchVerifyRequestSerializer {}
