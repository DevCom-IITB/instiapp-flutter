// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alumni_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

alumniLoginResponse _$alumniLoginResponseFromJson(Map<String, dynamic> json) =>
    alumniLoginResponse(
      ldap: json['ldap'] as String?,
      msg: json['msg'] as String?,
      exist: json['exist'] as bool?,
      error_status: json['error_status'] as bool?,
    )
      ..sessionid = json['sessionid'] as String?
      ..user = json['user'] as String?
      ..profileId = json['profile_id'] as String?
      ..profile = json['profile'] == null
          ? null
          : User.fromJson(json['profile'] as Map<String, dynamic>);

Map<String, dynamic> _$alumniLoginResponseToJson(
        alumniLoginResponse instance) =>
    <String, dynamic>{
      'ldap': instance.ldap,
      'msg': instance.msg,
      'exist': instance.exist,
      'error_status': instance.error_status,
      'sessionid': instance.sessionid,
      'user': instance.user,
      'profile_id': instance.profileId,
      'profile': instance.profile,
    };
