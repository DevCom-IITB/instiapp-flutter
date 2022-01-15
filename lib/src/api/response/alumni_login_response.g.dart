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
    );

Map<String, dynamic> _$alumniLoginResponseToJson(
        alumniLoginResponse instance) =>
    <String, dynamic>{
      'ldap': instance.ldap,
      'msg': instance.msg,
      'exist': instance.exist,
      'error_status': instance.error_status,
    };
