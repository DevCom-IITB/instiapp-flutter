// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      roleID: json['id'] as String?,
      roleName: json['name'] as String?,
      roleInheritable: json['inheritable'] as bool?,
      roleBody: json['body'] as String?,
      roleBodyDetails: json['body_detail'] == null
          ? null
          : Body.fromJson(json['body_detail'] as Map<String, dynamic>),
      roleBodies: (json['bodies'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      rolePermissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      roleUsers:
          (json['users'] as List<dynamic>?)?.map((e) => e as String).toList(),
      roleUsersDetail: (json['users_detail'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      year: json['year'] as String?,
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'id': instance.roleID,
      'name': instance.roleName,
      'inheritable': instance.roleInheritable,
      'body': instance.roleBody,
      'body_detail': instance.roleBodyDetails,
      'bodies': instance.roleBodies,
      'permissions': instance.rolePermissions,
      'users': instance.roleUsers,
      'users_detail': instance.roleUsersDetail,
      'year': instance.year,
    };
