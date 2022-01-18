import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alumni_login_response.g.dart';

@JsonSerializable()
class alumniLoginResponse {
  alumniLoginResponse({this.ldap, this.msg, this.exist, this.error_status});

  String? ldap;
  String? msg;
  bool? exist;
  bool? error_status;
  
  String? sessionid;
  String? user;

  @JsonKey(name: "profile_id")
  String? profileId;
  User? profile;

  /// A necessary factory constructor for creating a new alumniLoginResponse instance
  /// from a map. Pass the map to the generated `_$alumniLoginResponseFromJson()` constructor.
  /// The constructor is named after the source class, in this case, alumniLoginResponse.
  factory alumniLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$alumniLoginResponseFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$alumniLoginResponseToJson`.
  Map<String, dynamic> toJson() => _$alumniLoginResponseToJson(this);
}
