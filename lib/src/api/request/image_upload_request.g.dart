// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageUploadRequest _$ImageUploadRequestFromJson(Map<String, dynamic> json) =>
    ImageUploadRequest(
      base64Image: json['picture'] as String?,
    );

Map<String, dynamic> _$ImageUploadRequestToJson(ImageUploadRequest instance) =>
    <String, dynamic>{
      'picture': instance.base64Image,
    };
