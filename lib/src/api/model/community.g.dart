// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
      id: json['id'] as String?,
      name: json['name'] as String?,
      followersCount: (json['followers_count'] as num?)?.toInt(),
      about: json['about'] as String?,
      logoImg: json['logo_image'] as String?,
      coverImg: json['cover_image'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isUserFollowing: json['is_user_following'] as bool?,
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      strId: json['str_id'] as String?,
      body: json['body'] as String?,
    )..featuredPosts = (json['featured_posts'] as List<dynamic>?)
        ?.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
      'id': instance.id,
      'str_id': instance.strId,
      'name': instance.name,
      'about': instance.about,
      'description': instance.description,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'logo_image': instance.logoImg,
      'cover_image': instance.coverImg,
      'followers_count': instance.followersCount,
      'is_user_following': instance.isUserFollowing,
      'roles': instance.roles,
      'posts': instance.posts,
      'featured_posts': instance.featuredPosts,
      'body': instance.body,
    };
