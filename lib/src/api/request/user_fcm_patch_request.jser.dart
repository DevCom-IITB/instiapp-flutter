// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_fcm_patch_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$UserFCMPatchRequestSerializer
    implements Serializer<UserFCMPatchRequest> {
  @override
  Map<String, dynamic> toMap(UserFCMPatchRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'fcm_id', model.userFCMId);
    setMapValue(ret, 'android_version', model.userAndroidVersion);
    return ret;
  }

  @override
  UserFCMPatchRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = new UserFCMPatchRequest();
    obj.userFCMId = map['fcm_id'] as String;
    obj.userAndroidVersion = map['android_version'] as int;
    return obj;
  }
}
