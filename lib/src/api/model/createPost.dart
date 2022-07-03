import 'package:json_annotation/json_annotation.dart';

class CreatePost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "content")
  String? content;

  @JsonKey(name: "published")
  String? user;

  CreatePost({this.id, this.content, this.user});
}
