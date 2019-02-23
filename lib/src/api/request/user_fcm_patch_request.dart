import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'user_fcm_patch_request.jser.dart';

class UserFCMPatchRequest {
  @Alias("fcm_id")
  String userFCMId;

  @Alias("android_version")
  int userAndroidVersion;
}

@GenSerializer()
class UserFCMPatchRequestSerializer extends Serializer<UserFCMPatchRequest>
    with _$UserFCMPatchRequestSerializer {}
