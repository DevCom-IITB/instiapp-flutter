import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';

import 'package:json_annotation/json_annotation.dart';

part 'body.g.dart';

@JsonSerializable()
class Body {
  @JsonKey(name: "id")
  String? bodyID;

  @JsonKey(name: "str_id")
  String? bodyStrID;

  @JsonKey(name: "name")
  String? bodyName;

  @JsonKey(name: "short_description")
  String? bodyShortDescription;

  @JsonKey(name: "description")
  String? bodyDescription;

  @JsonKey(name: "image_url")
  String? bodyImageURL;

  @JsonKey(name: "children")
  List<Body>? bodyChildren;

  @JsonKey(name: "parents")
  List<Body>? bodyParents;

  @JsonKey(name: "events")
  List<Event>? bodyEvents;

  @JsonKey(name: "followers_count")
  int? bodyFollowersCount;

  @JsonKey(name: "website_url")
  String? bodyWebsiteURL;

  @JsonKey(name: "blog_url")
  String? bodyBlogURL;

  @JsonKey(name: "user_follows")
  bool? bodyUserFollows;

  @JsonKey(name: "roles")
  List<Role>? bodyRoles;

  @override
  String toString() {
    return bodyName ?? "";
  }

  Body(
      {this.bodyBlogURL,
      this.bodyChildren,
      this.bodyDescription,
      this.bodyEvents,
      this.bodyID,
      this.bodyFollowersCount,
      this.bodyImageURL,
      this.bodyName,
      this.bodyParents,
      this.bodyRoles,
      this.bodyShortDescription,
      this.bodyStrID,
      this.bodyUserFollows,
      this.bodyWebsiteURL});

  factory Body.fromJson(Map<String, dynamic> json) => _$BodyFromJson(json);

  Map<String, dynamic> toJson() => _$BodyToJson(this);
}
