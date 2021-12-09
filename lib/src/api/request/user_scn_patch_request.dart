import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user_scn_patch_request.g.dart';

class UserSCNPatchRequest {
  @JsonKey("show_contact_no")
  bool userShowContactNumber;

  UserSCNPatchRequest({this.userShowContactNumber});

  factory UserSCNPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$UserSCNPatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserSCNPatchRequestToJson(this);
}

@GenSerializer()
class UserSCNPatchRequestSerializer extends Serializer<UserSCNPatchRequest>
    with _$UserSCNPatchRequestSerializer {}
