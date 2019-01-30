// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$SessionSerializer implements Serializer<Session> {
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer =>
      __userSerializer ??= new UserSerializer();
  @override
  Map<String, dynamic> toMap(Session model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'sessionid', model.sessionid);
    setMapValue(ret, 'user', model.user);
    setMapValue(ret, 'profile_id', model.profileId);
    setMapValue(ret, 'profile', _userSerializer.toMap(model.profile));
    return ret;
  }

  @override
  Session fromMap(Map map) {
    if (map == null) return null;
    final obj = new Session();
    obj.sessionid = map['sessionid'] as String;
    obj.user = map['user'] as String;
    obj.profileId = map['profile_id'] as String;
    obj.profile = _userSerializer.fromMap(map['profile'] as Map);
    return obj;
  }
}

abstract class _$UserSerializer implements Serializer<User> {
  Serializer<Event> __eventSerializer;
  Serializer<Event> get _eventSerializer =>
      __eventSerializer ??= new EventSerializer();
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer =>
      __bodySerializer ??= new BodySerializer();
  Serializer<Role> __roleSerializer;
  Serializer<Role> get _roleSerializer =>
      __roleSerializer ??= new RoleSerializer();
  @override
  Map<String, dynamic> toMap(User model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.userID);
    setMapValue(ret, 'name', model.userName);
    setMapValue(ret, 'profile_pic', model.userProfilePictureUrl);
    setMapValue(
        ret,
        'events_interested',
        codeIterable(model.userInterestedEvents,
            (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(
        ret,
        'events_going',
        codeIterable(model.userGoingEvents,
            (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(ret, 'email', model.userEmail);
    setMapValue(ret, 'roll_no', model.userRollNumber);
    setMapValue(ret, 'contact_no', model.userContactNumber);
    setMapValue(ret, 'show_contact_no', model.userShowContactNumber);
    setMapValue(ret, 'about', model.userAbout);
    setMapValue(
        ret,
        'followed_bodies',
        codeIterable(model.userFollowedBodies,
            (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(ret, 'followed_bodies_id',
        codeIterable(model.userFollowedBodiesID, (val) => val as String));
    setMapValue(
        ret,
        'roles',
        codeIterable(
            model.userRoles, (val) => _roleSerializer.toMap(val as Role)));
    setMapValue(
        ret,
        'institute_roles',
        codeIterable(model.userInstituteRoles,
            (val) => _roleSerializer.toMap(val as Role)));
    setMapValue(
        ret,
        'former_roles',
        codeIterable(model.userFormerRoles,
            (val) => _roleSerializer.toMap(val as Role)));
    setMapValue(ret, 'website_url', model.userWebsiteURL);
    setMapValue(ret, 'ldap_id', model.userLDAPId);
    setMapValue(ret, 'hostel', model.hostel);
    setMapValue(ret, 'currentRole', model.currentRole);
    return ret;
  }

  @override
  User fromMap(Map map) {
    if (map == null) return null;
    final obj = new User();
    obj.userID = map['id'] as String;
    obj.userName = map['name'] as String;
    obj.userProfilePictureUrl = map['profile_pic'] as String;
    obj.userInterestedEvents = codeIterable<Event>(
        map['events_interested'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.userGoingEvents = codeIterable<Event>(map['events_going'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.userEmail = map['email'] as String;
    obj.userRollNumber = map['roll_no'] as String;
    obj.userContactNumber = map['contact_no'] as String;
    obj.userShowContactNumber = map['show_contact_no'] as bool;
    obj.userAbout = map['about'] as String;
    obj.userFollowedBodies = codeIterable<Body>(
        map['followed_bodies'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.userFollowedBodiesID = codeIterable<String>(
        map['followed_bodies_id'] as Iterable, (val) => val as String);
    obj.userRoles = codeIterable<Role>(
        map['roles'] as Iterable, (val) => _roleSerializer.fromMap(val as Map));
    obj.userInstituteRoles = codeIterable<Role>(
        map['institute_roles'] as Iterable,
        (val) => _roleSerializer.fromMap(val as Map));
    obj.userFormerRoles = codeIterable<Role>(map['former_roles'] as Iterable,
        (val) => _roleSerializer.fromMap(val as Map));
    obj.userWebsiteURL = map['website_url'] as String;
    obj.userLDAPId = map['ldap_id'] as String;
    obj.hostel = map['hostel'] as String;
    obj.currentRole = map['currentRole'] as String;
    return obj;
  }
}
