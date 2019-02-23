import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'image_upload_response.jser.dart';

class ImageUploadResponse {
  @Alias("id")
  String pictureID;
  @Alias("picture")
  String pictureURL;
}

@GenSerializer()
class ImageUploadResponseSerializer extends Serializer<ImageUploadResponse>
    with _$ImageUploadResponseSerializer {}
