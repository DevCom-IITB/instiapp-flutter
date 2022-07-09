import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'communityPost.g.dart';

@JsonSerializable()
class CommunityPost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "str_id")
  String? strId;

  @JsonKey(name: "content")
  String? content;

  @JsonKey(name: "posted_by")
  User? postedBy;

  @JsonKey(name: "reactions_count")
  Map<String, int>? reactionCount;

  @JsonKey(name: "user_reaction")
  int? userReaction;

  @JsonKey(name: "comments_count")
  int? commentsCount;

  @JsonKey(name: "time_of_creation")
  String? timeOfCreation;

  @JsonKey(name: "time_of_modification")
  String? timeOfModification;

  @JsonKey(name: "image_url")
  List<String>? imageUrl;

  @JsonKey(name: "most_liked_comment")
  CommunityPost? mostLikedComment;

  @JsonKey(name: "comments")
  List<CommunityPost>? comments;

  @JsonKey(name: "community")
  String? community;

  @JsonKey(name: "thread_rank")
  int? threadRank;

  @JsonKey(name: "parent")
  String? parent;

  CommunityPost({
    this.id,
    this.strId,
    this.comments,
    this.content,
    this.commentsCount,
    this.imageUrl,
    this.postedBy,
    this.reactionCount,
    this.timeOfCreation,
    this.timeOfModification,
    this.userReaction,
    this.mostLikedComment,
    this.community,
      this.threadRank,
      this.parent
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityPostToJson(this);
}
