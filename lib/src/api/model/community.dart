import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'community.g.dart';

@JsonSerializable()
class Community {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "str_id")
  String? strId;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "about")
  String? about;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "created_at")
  String? createdAt;

  @JsonKey(name: "updated_at")
  String? updatedAt;

  @JsonKey(name: "logo_image")
  String? logoImg;

  @JsonKey(name: "cover_image")
  String? coverImg;

  @JsonKey(name: "followers_count")
  int? followersCount;

  @JsonKey(name: "is_user_following")
  bool? isUserFollowing;

  @JsonKey(name: "roles")
  List<Role>? roles;

  @JsonKey(name: "posts")
  List<CommunityPost>? posts;

  Community({
    this.id,
    this.name,
    this.followersCount,
    this.about,
    this.logoImg,
    this.coverImg,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.isUserFollowing,
    this.posts,
    this.roles,
    this.strId,
  });

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityToJson(this);
}
