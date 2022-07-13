// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityPostListResponse _$CommunityPostListResponseFromJson(
        Map<String, dynamic> json) =>
    CommunityPostListResponse(
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommunityPostListResponseToJson(
        CommunityPostListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'data': instance.data,
    };
