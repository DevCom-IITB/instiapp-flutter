import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'image_upload_request.g.dart';

class ImageUploadRequest {
  @JsonKey("picture")
  String base64Image;

  ImageUploadRequest({this.base64Image});
  factory ImageUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadRequestToJson(this);
}

@GenSerializer()
class ImageUploadRequestSerializer extends Serializer<ImageUploadRequest>
    with _$ImageUploadRequestSerializer {}
