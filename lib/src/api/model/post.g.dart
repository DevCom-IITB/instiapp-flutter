// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String?,
      guid: json['guid'] as String?,
      link: json['link'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      published: json['published'] as String?,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
    };

PlacementBlogPost _$PlacementBlogPostFromJson(Map<String, dynamic> json) =>
    PlacementBlogPost(
      json['id'] as String?,
      json['guid'] as String?,
      json['link'] as String?,
      json['title'] as String?,
      json['content'] as String?,
      json['published'] as String?,
    );

Map<String, dynamic> _$PlacementBlogPostToJson(PlacementBlogPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
    };

ExternalBlogPost _$ExternalBlogPostFromJson(Map<String, dynamic> json) =>
    ExternalBlogPost(
      json['id'] as String?,
      json['guid'] as String?,
      json['link'] as String?,
      json['title'] as String?,
      json['content'] as String?,
      json['published'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$ExternalBlogPostToJson(ExternalBlogPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
      'body': instance.body,
    };

TrainingBlogPost _$TrainingBlogPostFromJson(Map<String, dynamic> json) =>
    TrainingBlogPost(
      json['id'] as String?,
      json['guid'] as String?,
      json['link'] as String?,
      json['title'] as String?,
      json['content'] as String?,
      json['published'] as String?,
    );

Map<String, dynamic> _$TrainingBlogPostToJson(TrainingBlogPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
    };

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
      json['id'] as String?,
      json['guid'] as String?,
      json['link'] as String?,
      json['title'] as String?,
      json['content'] as String?,
      json['published'] as String?,
      body: json['body'] == null
          ? null
          : Body.fromJson(json['body'] as Map<String, dynamic>),
      reactionCount: (json['reactions_count'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as int),
      ),
      userReaction: json['user_reaction'] as int?,
    );

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
      'body': instance.body,
      'reactions_count': instance.reactionCount,
      'user_reaction': instance.userReaction,
    };

ChatBot _$ChatBotFromJson(Map<String, dynamic> json) => ChatBot(
      json['id'] as String?,
      json['guid'] as String?,
      json['link'] as String?,
      json['title'] as String?,
      json['content'] as String?,
      json['published'] as String?,
      body: json['data'] as String?,
    );

Map<String, dynamic> _$ChatBotToJson(ChatBot instance) => <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'link': instance.link,
      'title': instance.title,
      'content': instance.content,
      'published': instance.published,
      'data': instance.body,
    };

Query _$QueryFromJson(Map<String, dynamic> json) => Query(
      content: json['answer'] as String?,
      published: json['category'] as String?,
      subCategory: json['sub_category'] as String?,
      subSubCategory: json['sub_sub_category'] as String?,
      title: json['question'] as String?,
    )..id = json['id'] as String?;

Map<String, dynamic> _$QueryToJson(Query instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.title,
      'answer': instance.content,
      'category': instance.published,
      'sub_category': instance.subCategory,
      'sub_sub_category': instance.subSubCategory,
    };
