import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'role.jser.dart';

class Role {
  @Alias("id")
  String roleID;

  @Alias("name")
  String roleName;

  @Alias("inheritable")
  bool roleInheritable;

  @Alias("body")
  String roleBody;

  @Alias("body_detail")
  Body roleBodyDetails;

  @Alias("bodies")
  List<Body> roleBodies;

  @Alias("permissions")
  List<String> rolePermissions;

  @Alias("users")
  List<String> roleUsers;

  @Alias("users_detail")
  List<User> roleUsersDetail;
}

@GenSerializer()
class RoleSerializer extends Serializer<Role> with _$RoleSerializer {}
