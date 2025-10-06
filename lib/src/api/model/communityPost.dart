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

  @JsonKey(name: "deleted")
  bool? deleted;

  @JsonKey(name: "anonymous")
  bool? anonymous;

  @JsonKey(name: "poll")
  Poll? poll;

  @JsonKey(ignore: true)
  int? postedMinutes;

  @JsonKey(name: "ispoll")
  bool? isPoll;

  // @JsonKey(name: "reported_by")
  // List<User>? reportedBy;

  @JsonKey(name: "has_user_reported")
  bool? hasUserReported;
  @override
  String toString() {
    return 'CommunityPost{id:$id, content:$content}';
  }

  CommunityPost copyWith({
    String? id,
    String? content,
    Poll? poll, // Make the poll field replaceable
    // ... other fields
  }) {
    return CommunityPost(
      id: id ?? this.id,
      content: content ?? this.content,
      poll: poll ?? this.poll,
      // ... other fields
    );
  }

  CommunityPost({
    this.id,
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
    this.parent,
    this.status,
    this.interests,
    this.users,
    this.bodies,
    this.featured,
    this.deleted,
    this.anonymous,
    this.hasUserReported,
    this.poll,
    this.isPoll,
    // this.reportedBy,
  }) {
    if (timeOfCreation != null) {
      postedMinutes =
          DateTime.now().difference(DateTime.parse(timeOfCreation!)).inMinutes;
    }
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityPostToJson(this);
}


@JsonSerializable()
class Poll {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "question")
  String? question;

  @JsonKey(name: "allow_multiple_answers")
  bool? allowMultipleAnswers;

  @JsonKey(name: "created_at")
  String? createdAt;

  @JsonKey(name: "options")
  List<PollOption>? options;

  @JsonKey(name: "total_votes")
  int? totalVotes;

  @JsonKey(name: "user_voted")
  bool? userVoted;

  Poll({
    this.id,
    this.question,
    this.allowMultipleAnswers,
    this.createdAt,
    this.options,
    this.totalVotes,
    this.userVoted,
  });

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
  Map<String, dynamic> toJson() => _$PollToJson(this);
}

@JsonSerializable()
class PollOption {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "text")
  String? text;

  @JsonKey(name: "order")
  int? order;

  @JsonKey(name: "vote_count")
  int? voteCount;

  @JsonKey(name: "percentage")
  double? percentage;

  @JsonKey(name: "user_voted")
  bool? userVoted;

  PollOption({
    this.id,
    this.text,
    this.order,
    this.voteCount,
    this.percentage,
    this.userVoted,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);
  Map<String, dynamic> toJson() => _$PollOptionToJson(this);
}

@JsonSerializable()
class PollVoteResponse {
    final String message;
    final Poll poll;

    PollVoteResponse({required this.message, required this.poll});
    
    factory PollVoteResponse.fromJson(Map<String, dynamic> json) => _$PollVoteResponseFromJson(json);
    Map<String, dynamic> toJson() => _$PollVoteResponseToJson(this);
}