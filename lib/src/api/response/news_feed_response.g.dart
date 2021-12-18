// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsFeedResponse _$NewsFeedResponseFromJson(Map<String, dynamic> json) =>
    NewsFeedResponse(
      (json['data'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['count'] as int?,
    );

Map<String, dynamic> _$NewsFeedResponseToJson(NewsFeedResponse instance) =>
    <String, dynamic>{
      'data': instance.events,
      'count': instance.count,
    };
