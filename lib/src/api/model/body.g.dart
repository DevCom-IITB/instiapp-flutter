// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Body _$BodyFromJson(Map<String, dynamic> json) => Body(
      bodyBlogURL: json['blog_url'] as String?,
      bodyChildren: (json['children'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyDescription: json['description'] as String?,
      bodyEvents: (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyID: json['id'] as String?,
      bodyFollowersCount: (json['followers_count'] as num?)?.toInt(),
      bodyImageURL: json['image_url'] as String?,
      bodyName: json['name'] as String?,
      bodyParents: (json['parents'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyRoles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyShortDescription: json['short_description'] as String?,
      bodyStrID: json['str_id'] as String?,
      bodyUserFollows: json['user_follows'] as bool?,
      bodyWebsiteURL: json['website_url'] as String?,
    );

Map<String, dynamic> _$BodyToJson(Body instance) => <String, dynamic>{
      'id': instance.bodyID,
      'str_id': instance.bodyStrID,
      'name': instance.bodyName,
      'short_description': instance.bodyShortDescription,
      'description': instance.bodyDescription,
      'image_url': instance.bodyImageURL,
      'children': instance.bodyChildren,
      'parents': instance.bodyParents,
      'events': instance.bodyEvents,
      'followers_count': instance.bodyFollowersCount,
      'website_url': instance.bodyWebsiteURL,
      'blog_url': instance.bodyBlogURL,
      'user_follows': instance.bodyUserFollows,
      'roles': instance.bodyRoles,
    };
