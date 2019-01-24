import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user.jser.dart';

class Session {
  String sessionid;
  String user;

  @Alias('profile_id')
  String profileId;
  User profile;
}

class User {
  @Alias("id")
  String userID;

  @Alias("name")
  String name;

  String _userName;
  String get userName {
    if (_userName == null) {
      _userName =
          name.toLowerCase().splitMapJoin(RegExp("\\s+"), onMatch: (m) => " ", onNonMatch: (word) => capitalize(word.toLowerCase()));
    }
    return _userName;
  }

  @Alias("profile_pic")
  String userProfilePictureUrl;

  @Alias("events_interested")
  List<Event> userInterestedEvents;

  @Alias("events_going")
  List<Event> userGoingEvents;

  @Alias("email")
  String userEmail;

  @Alias("roll_no")
  String userRollNumber;

  @Alias("contact_no")
  String userContactNumber;

  @Alias("about")
  String userAbout;

  @Alias("followed_bodies")
  List<Body> userFollowedBodies;

  @Alias("followed_bodies_id")
  List<String> userFollowedBodiesID;

  @Alias("roles")
  List<Role> userRoles;

  @Alias("institute_roles")
  List<Role> userInstituteRoles;

  @Alias("former_roles")
  List<Role> userFormerRoles;

  @Alias("website_url")
  String userWebsiteURL;

  @Alias("ldap_id")
  String userLDAPId;

  @Alias("hostel")
  String hostel;

  String currentRole;

  String getSubTitle() {
    return currentRole ?? userLDAPId;
  }
}

@GenSerializer(serializers: const [UserSerializer])
class SessionSerializer extends Serializer<Session> with _$SessionSerializer {}

@GenSerializer()
class UserSerializer extends Serializer<User> with _$UserSerializer {}
