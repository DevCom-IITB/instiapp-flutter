import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'communityPost.g.dart';

@JsonSerializable()
class CommunityPost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "str_id")
  String? communityPostStrId;

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
  Community? community;

  @JsonKey(name: "thread_rank")
  int? threadRank;

  @JsonKey(name: "parent")
  String? parent;

  @JsonKey(name: "status")
  int? status;

  @JsonKey(name: "interests")
  List<Interest>? interests;

  @JsonKey(name: "tag_user")
  List<User>? users;

  @JsonKey(name: "tag_body")
  List<Body>? bodies;

  @JsonKey(name: "featured")
  bool? featured;

  @JsonKey(ignore: true)
  int? postedMinutes;

  @override
  String toString() {
    return 'CommunityPost{id:$id, content:$content}';
  }

  CommunityPost(
      {this.id,
      this.communityPostStrId,
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
      this.parent}) {
    if (timeOfCreation != null) {
      postedMinutes =
          DateTime.now().difference(DateTime.parse(timeOfCreation!)).inMinutes;
    }
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityPostToJson(this);
}
