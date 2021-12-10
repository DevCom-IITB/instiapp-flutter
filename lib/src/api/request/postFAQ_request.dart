import 'package:json_annotation/json_annotation.dart';

part 'postFAQ_request.jser.dart';

@JsonSerializable()
class PostFAQRequest {
  @JsonKey(name: "question")
  String? question;

  @JsonKey(name: "category")
  String? category;

  PostFAQRequest({
    this.category,
    this.question
  });

  factory PostFAQRequest.fromJson(Map<String, dynamic> json) =>
      _$PostFAQRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostFAQRequestToJson(this);
}
