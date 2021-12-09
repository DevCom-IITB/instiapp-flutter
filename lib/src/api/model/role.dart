import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'role.g.dart';

class Role {
  @JsonKey("id")
  String roleID;

  @JsonKey("name")
  String roleName;

  @JsonKey("inheritable")
  bool roleInheritable;

  @JsonKey("body")
  String roleBody;

  @JsonKey("body_detail")
  Body roleBodyDetails;

  @JsonKey("bodies")
  List<Body> roleBodies;

  @JsonKey("permissions")
  List<String> rolePermissions;

  @JsonKey("users")
  List<String> roleUsers;

  @JsonKey("users_detail")
  List<User> roleUsersDetail;

  @JsonKey("year")
  String year;

  Role({this.roleID, this.roleName, this.roleInheritable, this.roleBody, this.roleBodyDetails, this.roleBodies, this.rolePermissions, this.roleUsers, this.roleUsersDetail, this.year});
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@GenSerializer()
class RoleSerializer extends Serializer<Role> with _$RoleSerializer {}
