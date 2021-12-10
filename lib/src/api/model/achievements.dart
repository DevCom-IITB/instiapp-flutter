import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';

part 'achievements.g.dart';

class Achievement {
  @JsonKey(name:"id")
  String id;

  @JsonKey(name:"time_of_creation")
  String timeOfCreation;

  @JsonKey(name:"time_of_modification")
  String timeOfModification;

  @JsonKey(name:"user")
  User user;

  @JsonKey(name:"hidden")
  bool hidden;

  @JsonKey(name:"dismissed")
  bool dismissed;

  @JsonKey(name:"verified")
  bool verified;

  @JsonKey(name:"verified_by")
  User verifiedBy;

  @JsonKey(name:"title")
  String title;

  @JsonKey(name:"description")
  String description;

  @JsonKey(name:"admin_note")
  String adminNote;

  @JsonKey(name:"body_detail")
  Body body;

  @JsonKey(name:"event_detail")
  Event event;

  @JsonKey(name:"offer")
  String offer;
}
