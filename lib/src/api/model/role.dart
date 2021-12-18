import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable()
class Role {
  @JsonKey(name: "id")
  String? roleID;

  @JsonKey(name: "name")
  String? roleName;

  @JsonKey(name: "inheritable")
  bool? roleInheritable;

  @JsonKey(name: "body")
  String? roleBody;

  @JsonKey(name: "body_detail")
  Body? roleBodyDetails;

  @JsonKey(name: "bodies")
  List<Body>? roleBodies;

  @JsonKey(name: "permissions")
  List<String>? rolePermissions;

  @JsonKey(name: "users")
  List<String>? roleUsers;

  @JsonKey(name: "users_detail")
  List<User>? roleUsersDetail;

  @JsonKey(name: "year")
  String? year;

  Role({this.roleID, this.roleName, this.roleInheritable, this.roleBody, this.roleBodyDetails, this.roleBodies, this.rolePermissions, this.roleUsers, this.roleUsersDetail, this.year});
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
