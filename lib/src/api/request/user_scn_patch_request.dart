import 'package:json_annotation/json_annotation.dart';

part 'user_scn_patch_request.g.dart';

@JsonSerializable()
class UserSCNPatchRequest {
  @JsonKey(name: "show_contact_no")
  bool? userShowContactNumber;

  UserSCNPatchRequest({this.userShowContactNumber});

  factory UserSCNPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$UserSCNPatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserSCNPatchRequestToJson(this);
}
