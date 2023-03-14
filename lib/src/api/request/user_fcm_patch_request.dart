import 'package:json_annotation/json_annotation.dart';

part 'user_fcm_patch_request.g.dart';

@JsonSerializable()
class UserFCMPatchRequest {
  @JsonKey(name: "fcm_id")
  String? userFCMId;

  @JsonKey(name: "android_version")
  int? userAndroidVersion;

  UserFCMPatchRequest({this.userFCMId, this.userAndroidVersion});
  factory UserFCMPatchRequest.fromJson(Map<String, dynamic> json) =>
      _$UserFCMPatchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserFCMPatchRequestToJson(this);
}
