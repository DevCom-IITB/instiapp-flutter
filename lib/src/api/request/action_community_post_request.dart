import 'package:json_annotation/json_annotation.dart';

part 'action_community_post_request.g.dart';

@JsonSerializable()
class ActionCommunityPostRequest {
  @JsonKey(name: "is_featured")
  bool? isFeatured;

  ActionCommunityPostRequest({this.isFeatured});

  factory ActionCommunityPostRequest.fromJson(Map<String, dynamic> json) =>
      _$ActionCommunityPostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ActionCommunityPostRequestToJson(this);
}
