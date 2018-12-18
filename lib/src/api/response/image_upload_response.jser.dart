// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ImageUploadResponseSerializer
    implements Serializer<ImageUploadResponse> {
  @override
  Map<String, dynamic> toMap(ImageUploadResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.pictureID);
    setMapValue(ret, 'picture', model.pictureURL);
    return ret;
  }

  @override
  ImageUploadResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new ImageUploadResponse();
    obj.pictureID = map['id'] as String;
    obj.pictureURL = map['picture'] as String;
    return obj;
  }
}
