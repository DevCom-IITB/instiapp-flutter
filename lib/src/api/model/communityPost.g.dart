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
      commentsCount: json['comments_count'] as int?,
      imageUrl: (json['image_url'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      postedBy: json['posted_by'] == null
          ? null
          : User.fromJson(json['posted_by'] as Map<String, dynamic>),
      reactionCount: (json['reactions_count'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as int),
      ),
      timeOfCreation: json['time_of_creation'] as String?,
      timeOfModification: json['time_of_modification'] as String?,
      userReaction: json['user_reaction'] as int?,
      mostLikedComment: json['most_liked_comment'] == null
          ? null
          : CommunityPost.fromJson(
              json['most_liked_comment'] as Map<String, dynamic>),
      community: json['community'] as String?,
      threadRank: json['thread_rank'] as int?,
      parent: json['parent'] as String?,
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
    };
