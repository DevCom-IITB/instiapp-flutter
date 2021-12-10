import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class Session {
  String? sessionid;
  String? user;

  @JsonKey(name: "profile_id")
  String? profileId;
  User? profile;

  Session({this.sessionid, this.user, this.profileId, this.profile});
  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  String? userID;

  @JsonKey(name: "name")
  String? userName;

  @JsonKey(name: "profile_pic")
  String? userProfilePictureUrl;

  @JsonKey(name: "events_interested")
  List<Event>? userInterestedEvents;

  @JsonKey(name: "events_going")
  List<Event>? userGoingEvents;

  @JsonKey(name: "email")
  String? userEmail;

  @JsonKey(name: "roll_no")
  String? userRollNumber;

  @JsonKey(name: "contact_no")
  String? userContactNumber;

  @JsonKey(name: "show_contact_no")
  bool? userShowContactNumber;

  @JsonKey(name: "about")
  String? userAbout;

  @JsonKey(name: "followed_bodies")
  List<Body>? userFollowedBodies;

  @JsonKey(name: "followed_bodies_id")
  List<String>? userFollowedBodiesID;

  @JsonKey(name: "roles")
  List<Role>? userRoles;

  @JsonKey(name: "institute_roles")
  List<Role>? userInstituteRoles;

  @JsonKey(name: "former_roles")
  List<Role>? userFormerRoles;

  @JsonKey(name: "website_url")
  String? userWebsiteURL;

  @JsonKey(name: "ldap_id")
  String? userLDAPId;

  @JsonKey(name: "hostel")
  String? hostel;

  String? currentRole;

  String? getSubTitle() {
    return currentRole ?? userLDAPId;
  }

  User(
      {this.userID,
      this.userName,
      this.userProfilePictureUrl,
      this.userInterestedEvents,
      this.userGoingEvents,
      this.userEmail,
      this.userRollNumber,
      this.userContactNumber,
      this.currentRole,
      this.hostel,
      this.userAbout,
      this.userFollowedBodies,
      this.userFollowedBodiesID,
      this.userFormerRoles,
      this.userInstituteRoles,
      this.userLDAPId,
      this.userRoles,
      this.userShowContactNumber,
      this.userWebsiteURL
      });
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
