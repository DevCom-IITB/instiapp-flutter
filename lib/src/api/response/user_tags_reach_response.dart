import 'package:json_annotation/json_annotation.dart';

part 'user_tags_reach_response.g.dart';

@JsonSerializable()
class UserTagsReachResponse {
  @JsonKey(name: "count")
  int? count;

  UserTagsReachResponse(this.count);
  factory UserTagsReachResponse.fromJson(Map<String, dynamic> json) =>
      _$UserTagsReachResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagsReachResponseToJson(this);
}
