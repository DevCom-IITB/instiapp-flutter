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
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'profile_pic', model.profilePicUrl);
    setMapValue(ret, 'email', model.email);
    setMapValue(ret, 'roll_no', model.rollNo);
    setMapValue(ret, 'hostel', model.hostel);
    setMapValue(ret, 'contact_no', model.contactNo);
    setMapValue(ret, 'about', model.about);
    setMapValue(ret, 'website_url', model.websiteUrl);
    setMapValue(ret, 'ldap_id', model.ldapId);
    setMapValue(
        ret,
        'events_interested',
        codeIterable(model.eventsInterested,
            (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(
        ret,
        'events_going',
        codeIterable(
            model.eventsGoing, (val) => _eventSerializer.toMap(val as Event)));
    setMapValue(
        ret,
        'followedBodies',
        codeIterable(
            model.followedBodies, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(ret, 'roles',
        codeIterable(model.roles, (val) => _roleSerializer.toMap(val as Role)));
    setMapValue(
        ret,
        'institute_roles',
        codeIterable(
            model.instituteRoles, (val) => _roleSerializer.toMap(val as Role)));
    setMapValue(
        ret,
        'former_roles',
        codeIterable(
            model.formerRoles, (val) => _roleSerializer.toMap(val as Role)));
    return ret;
  }

  @override
  User fromMap(Map map) {
    if (map == null) return null;
    final obj = new User();
    obj.id = map['id'] as String;
    obj.name = map['name'] as String;
    obj.profilePicUrl = map['profile_pic'] as String;
    obj.email = map['email'] as String;
    obj.rollNo = map['roll_no'] as String;
    obj.hostel = map['hostel'] as String;
    obj.contactNo = map['contact_no'] as String;
    obj.about = map['about'] as String;
    obj.websiteUrl = map['website_url'] as String;
    obj.ldapId = map['ldap_id'] as String;
    obj.eventsInterested = codeIterable<Event>(
        map['events_interested'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.eventsGoing = codeIterable<Event>(map['events_going'] as Iterable,
        (val) => _eventSerializer.fromMap(val as Map));
    obj.followedBodies = codeIterable<Body>(map['followedBodies'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.roles = codeIterable<Role>(
        map['roles'] as Iterable, (val) => _roleSerializer.fromMap(val as Map));
    obj.instituteRoles = codeIterable<Role>(map['institute_roles'] as Iterable,
        (val) => _roleSerializer.fromMap(val as Map));
    obj.formerRoles = codeIterable<Role>(map['former_roles'] as Iterable,
        (val) => _roleSerializer.fromMap(val as Map));
    return obj;
  }
}
