import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'body.jser.dart';

class Body {
  String id;

  @Alias('str_id')
  String strId;

  String name;

  @Alias('short_description')
  String shortDescription;

  @Alias('website_url')
  String websiteUrl;

  @Alias('image_url')
  String imageUrl;

  @Alias('cover_url')
  String coverUrl;
}

@GenSerializer()
class BodySerializer extends Serializer<Body> with _$BodySerializer {}