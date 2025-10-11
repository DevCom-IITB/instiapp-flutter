// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communityPost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityPost _$CommunityPostFromJson(Map<String, dynamic> json) =>
    CommunityPost(
      id: json['id'] as String?,
      communityPostStrId: json['str_id'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      content: json['content'] as String?,
      commentsCount: (json['comments_count'] as num?)?.toInt(),
      imageUrl: (json['image_url'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      postedBy: json['posted_by'] == null
          ? null
          : User.fromJson(json['posted_by'] as Map<String, dynamic>),
      reactionCount: (json['reactions_count'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      timeOfCreation: json['time_of_creation'] as String?,
      timeOfModification: json['time_of_modification'] as String?,
      userReaction: (json['user_reaction'] as num?)?.toInt(),
      mostLikedComment: json['most_liked_comment'] == null
          ? null
          : CommunityPost.fromJson(
              json['most_liked_comment'] as Map<String, dynamic>),
      community: json['community'] == null
          ? null
          : Community.fromJson(json['community'] as Map<String, dynamic>),
      threadRank: (json['thread_rank'] as num?)?.toInt(),
      parent: json['parent'] as String?,
      status: (json['status'] as num?)?.toInt(),
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (json['tag_user'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodies: (json['tag_body'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      featured: json['featured'] as bool?,
      deleted: json['deleted'] as bool?,
      anonymous: json['anonymous'] as bool?,
      hasUserReported: json['has_user_reported'] as bool?,
      poll: json['poll'] == null
          ? null
          : Poll.fromJson(json['poll'] as Map<String, dynamic>),
      isPoll: json['ispoll'] as bool?,
    );

Map<String, dynamic> _$CommunityPostToJson(CommunityPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'str_id': instance.communityPostStrId,
      'content': instance.content,
      'posted_by': instance.postedBy,
      'reactions_count': instance.reactionCount,
      'user_reaction': instance.userReaction,
      'comments_count': instance.commentsCount,
      'time_of_creation': instance.timeOfCreation,
      'time_of_modification': instance.timeOfModification,
      'image_url': instance.imageUrl,
      'most_liked_comment': instance.mostLikedComment,
      'comments': instance.comments,
      'community': instance.community,
      'thread_rank': instance.threadRank,
      'parent': instance.parent,
      'status': instance.status,
      'interests': instance.interests,
      'tag_user': instance.users,
      'tag_body': instance.bodies,
      'featured': instance.featured,
      'deleted': instance.deleted,
      'anonymous': instance.anonymous,
      'poll': instance.poll,
      'ispoll': instance.isPoll,
      'has_user_reported': instance.hasUserReported,
    };

Poll _$PollFromJson(Map<String, dynamic> json) => Poll(
      id: json['id'] as String?,
      question: json['question'] as String?,
      allowMultipleAnswers: json['allow_multiple_answers'] as bool?,
      createdAt: json['created_at'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalVotes: (json['total_votes'] as num?)?.toInt(),
      userVoted: json['user_voted'] as bool?,
    );

Map<String, dynamic> _$PollToJson(Poll instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'allow_multiple_answers': instance.allowMultipleAnswers,
      'created_at': instance.createdAt,
      'options': instance.options,
      'total_votes': instance.totalVotes,
      'user_voted': instance.userVoted,
    };

PollOption _$PollOptionFromJson(Map<String, dynamic> json) => PollOption(
      id: json['id'] as String?,
      text: json['text'] as String?,
      order: (json['order'] as num?)?.toInt(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      userVoted: json['user_voted'] as bool?,
    );

Map<String, dynamic> _$PollOptionToJson(PollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'order': instance.order,
      'vote_count': instance.voteCount,
      'percentage': instance.percentage,
      'user_voted': instance.userVoted,
    };

PollVoteResponse _$PollVoteResponseFromJson(Map<String, dynamic> json) =>
    PollVoteResponse(
      message: json['message'] as String,
      poll: Poll.fromJson(json['poll'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PollVoteResponseToJson(PollVoteResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'poll': instance.poll,
    };
