import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'postFAQ_request.jser.dart';

class PostFAQRequest {
  @Alias("question")
  String question;

  @Alias("category")
  String category;
}

@GenSerializer()
class PostFAQRequestSerializer extends Serializer<PostFAQRequest>
    with _$PostFAQRequestSerializer {}
