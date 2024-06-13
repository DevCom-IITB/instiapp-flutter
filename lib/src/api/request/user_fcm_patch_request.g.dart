// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_fcm_patch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFCMPatchRequest _$UserFCMPatchRequestFromJson(Map<String, dynamic> json) =>
    UserFCMPatchRequest(
      userFCMId: json['fcm_id'] as String?,
      userAndroidVersion: (json['android_version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserFCMPatchRequestToJson(
        UserFCMPatchRequest instance) =>
    <String, dynamic>{
      'fcm_id': instance.userFCMId,
      'android_version': instance.userAndroidVersion,
    };
