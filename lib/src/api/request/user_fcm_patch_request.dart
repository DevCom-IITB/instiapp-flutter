import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user_fcm_patch_request.g.dart';

class UserFCMPatchRequest {
  @JsonKey("fcm_id")
  String userFCMId;

  @JsonKey("android_version")
  int userAndroidVersion;

  UserFCMPatchRequest({this.userFCMId, this.userAndroidVersion});
  factory UserFCMPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$UserFCMPatchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserFCMPatchRequestToJson(this);
}

@GenSerializer()
class UserFCMPatchRequestSerializer extends Serializer<UserFCMPatchRequest>
    with _$UserFCMPatchRequestSerializer {}
