// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buynsellPostsPage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuynSellPostsPage _$BuynSellPostsPageFromJson(Map<String, dynamic> json) =>
    BuynSellPostsPage(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => BuynSellPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BuynSellPostsPageToJson(BuynSellPostsPage instance) =>
    <String, dynamic>{
      'results': instance.results,
    };
