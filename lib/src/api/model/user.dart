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
  String id;
  String name;
  
  @Alias('profile_pic')
  String profilePicUrl;

  String email;
  
  @Alias('roll_no')
  String rollNo;

  String hostel;
  
  @Alias('contact_no')
  String contactNo;
  String about;


  @Alias('website_url')
  String websiteUrl;
  
  @Alias('ldap_id')
  String ldapId;

  // TODO: Other misc. things

  // List<Event> events_interested;
  // List<Event> events_going;

  // List<Body> followedBodies;
  // List<Role> roles;
  
  // @Alias('institute_roles')
  // List<Role> instituteRoles;

  // @Alias('former_roles')
  // List<Role> formerRoles;
}

@GenSerializer(serializers: const [UserSerializer])
class SessionSerializer extends Serializer<Session> with _$SessionSerializer {}

@GenSerializer()
class UserSerializer extends Serializer<User> with _$UserSerializer {}