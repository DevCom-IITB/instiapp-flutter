import 'package:json_annotation/json_annotation.dart';

part 'comment_create_request.g.dart';

@JsonSerializable()
class CommentCreateRequest {
  @JsonKey(name: "text")
  String? text;

  CommentCreateRequest({this.text});
  factory CommentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CommentCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CommentCreateRequestToJson(this);
}
