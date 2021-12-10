import 'package:json_annotation/json_annotation.dart';
part 'image_upload_response.g.dart';

@JsonSerializable()
class ImageUploadResponse {
  @JsonKey(name: "id")
  String? pictureID;
  @JsonKey(name: "picture")
  String? pictureURL;

  ImageUploadResponse({this.pictureID, this.pictureURL});
  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadResponseToJson(this);
}
