import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'image_upload_response.g.dart';

class ImageUploadResponse {
  @JsonKey("id")
  String pictureID;
  @JsonKey("picture")
  String pictureURL;

  ImageUploadResponse({this.pictureID, this.pictureURL});
  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadResponseToJson(this);
}

@GenSerializer()
class ImageUploadResponseSerializer extends Serializer<ImageUploadResponse>
    with _$ImageUploadResponseSerializer {}
