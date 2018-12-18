import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'comment_create_request.jser.dart';

class CommentCreateRequest {
  @Alias("text")
  String text;
}

@GenSerializer()
class CommentCreateRequestSerializer extends Serializer<CommentCreateRequest> with _$CommentCreateRequestSerializer {}