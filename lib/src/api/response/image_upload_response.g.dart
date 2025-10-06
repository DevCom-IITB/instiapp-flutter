// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) =>
    ImageUploadResponse(
      pictureID: json['id'] as String?,
      pictureURL: json['file'] as String?,
    );

Map<String, dynamic> _$ImageUploadResponseToJson(
        ImageUploadResponse instance) =>
    <String, dynamic>{
      'id': instance.pictureID,
      'file': instance.pictureURL,
    };
