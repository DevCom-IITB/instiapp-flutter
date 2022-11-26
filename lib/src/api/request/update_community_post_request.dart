import 'package:json_annotation/json_annotation.dart';

part 'update_community_post_request.g.dart';

@JsonSerializable()
class UpdateCommunityPostRequest {
  @JsonKey(name: "status")
  int? status;

  UpdateCommunityPostRequest({this.status});

  factory UpdateCommunityPostRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommunityPostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCommunityPostRequestToJson(this);
}
