import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'comment_create_request.g.dart';

class CommentCreateRequest {
  @JsonKey("text")
  String text;

  CommentCreateRequest({this.text});
  factory CommentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CommentCreateRequestToJson(this);
}

@GenSerializer()
class CommentCreateRequestSerializer extends Serializer<CommentCreateRequest>
    with _$CommentCreateRequestSerializer {}
