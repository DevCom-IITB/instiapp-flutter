import 'package:json_annotation/json_annotation.dart';

part 'image_upload_request.g.dart';

@JsonSerializable()
class ImageUploadRequest {
  @JsonKey(name: "picture")
  String? base64Image;

  ImageUploadRequest({this.base64Image});
  factory ImageUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadRequestToJson(this);
}
