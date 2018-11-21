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
    return obj;
  }
}
