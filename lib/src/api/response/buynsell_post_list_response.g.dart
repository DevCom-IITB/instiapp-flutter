// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buynsell_post_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuynSellPostListResponse _$BuynSellPostListResponseFromJson(
        Map<String, dynamic> json) =>
    BuynSellPostListResponse(
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BuynSellPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BuynSellPostListResponseToJson(
        BuynSellPostListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'data': instance.data,
    };
