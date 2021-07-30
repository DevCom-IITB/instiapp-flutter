// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$RoleSerializer implements Serializer<Role> {
  Serializer<Body> __bodySerializer;
  Serializer<Body> get _bodySerializer => __bodySerializer ??= BodySerializer();
  Serializer<User> __userSerializer;
  Serializer<User> get _userSerializer => __userSerializer ??= UserSerializer();
  @override
  Map<String, dynamic> toMap(Role model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.roleID);
    setMapValue(ret, 'name', model.roleName);
    setMapValue(ret, 'inheritable', model.roleInheritable);
    setMapValue(ret, 'body', model.roleBody);
    setMapValue(
        ret, 'body_detail', _bodySerializer.toMap(model.roleBodyDetails));
    setMapValue(
        ret,
        'bodies',
        codeIterable(
            model.roleBodies, (val) => _bodySerializer.toMap(val as Body)));
    setMapValue(ret, 'permissions',
        codeIterable(model.rolePermissions, (val) => val as String));
    setMapValue(
        ret, 'users', codeIterable(model.roleUsers, (val) => val as String));
    setMapValue(
        ret,
        'users_detail',
        codeIterable(model.roleUsersDetail,
            (val) => _userSerializer.toMap(val as User)));
    setMapValue(ret, 'year', model.year);
    return ret;
  }

  @override
  Role fromMap(Map map) {
    if (map == null) return null;
    final obj = Role();
    obj.roleID = map['id'] as String;
    obj.roleName = map['name'] as String;
    obj.roleInheritable = map['inheritable'] as bool;
    obj.roleBody = map['body'] as String;
    obj.roleBodyDetails = _bodySerializer.fromMap(map['body_detail'] as Map);
    obj.roleBodies = codeIterable<Body>(map['bodies'] as Iterable,
        (val) => _bodySerializer.fromMap(val as Map));
    obj.rolePermissions = codeIterable<String>(
        map['permissions'] as Iterable, (val) => val as String);
    obj.roleUsers =
        codeIterable<String>(map['users'] as Iterable, (val) => val as String);
    obj.roleUsersDetail = codeIterable<User>(map['users_detail'] as Iterable,
        (val) => _userSerializer.fromMap(val as Map));
    obj.year = map['year'] as String;
    return obj;
  }
}
