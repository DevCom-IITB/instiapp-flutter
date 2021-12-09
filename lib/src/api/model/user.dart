import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user.g.dart';

class Session {
  String sessionid;
  String user;

  @JsonKey('profile_id')
  String profileId;
  User profile;

  Session(this.sessionid, this.user, this.profileId, this.profile);
  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}

class User {
  @JsonKey("id")
  String userID;

  @JsonKey("name")
  String userName;

  @JsonKey("profile_pic")
  String userProfilePictureUrl;

  @JsonKey("events_interested")
  List<Event> userInterestedEvents;

  @JsonKey("events_going")
  List<Event> userGoingEvents;

  @JsonKey("email")
  String userEmail;

  @JsonKey("roll_no")
  String userRollNumber;

  @JsonKey("contact_no")
  String userContactNumber;

  @JsonKey("show_contact_no")
  bool userShowContactNumber;

  @JsonKey("about")
  String userAbout;

  @JsonKey("followed_bodies")
  List<Body> userFollowedBodies;

  @JsonKey("followed_bodies_id")
  List<String> userFollowedBodiesID;

  @JsonKey("roles")
  List<Role> userRoles;

  @JsonKey("institute_roles")
  List<Role> userInstituteRoles;

  @JsonKey("former_roles")
  List<Role> userFormerRoles;

  @JsonKey("website_url")
  String userWebsiteURL;

  @JsonKey("ldap_id")
  String userLDAPId;

  @JsonKey("hostel")
  String hostel;

  String currentRole;

  String getSubTitle() {
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
      this.userContactNumber,});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@GenSerializer(serializers: const [UserSerializer])
class SessionSerializer extends Serializer<Session> with _$SessionSerializer {}

@GenSerializer()
class UserSerializer extends Serializer<User> with _$UserSerializer {}
