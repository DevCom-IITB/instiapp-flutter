// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$LoginResponseSerializer implements Serializer<LoginResponse> {
  @override
  Map<String, dynamic> toMap(LoginResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'sessionid', model.sessionID);
    setMapValue(ret, 'user', model.userID);
    setMapValue(ret, 'profile_id', model.profileID);
    return ret;
  }

  @override
  LoginResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new LoginResponse();
    obj.sessionID = map['sessionid'] as String;
    obj.userID = map['user'] as String;
    obj.profileID = map['profile_id'] as String;
    return obj;
  }
}
