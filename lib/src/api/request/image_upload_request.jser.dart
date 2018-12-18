// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ImageUploadRequestSerializer
    implements Serializer<ImageUploadRequest> {
  @override
  Map<String, dynamic> toMap(ImageUploadRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'picture', model.base64Image);
    return ret;
  }

  @override
  ImageUploadRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = new ImageUploadRequest();
    obj.base64Image = map['picture'] as String;
    return obj;
  }
}
