import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'image_upload_request.jser.dart';

class ImageUploadRequest {
  @Alias("picture")
  String base64Image;
}

@GenSerializer()
class ImageUploadRequestSerializer extends Serializer<ImageUploadRequest>
    with _$ImageUploadRequestSerializer {}
