// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserTag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTag _$UserTagFromJson(Map<String, dynamic> json) => UserTag(
      tagID: (json['id'] as num?)?.toInt(),
      tagName: json['name'] as String?,
    );

Map<String, dynamic> _$UserTagToJson(UserTag instance) => <String, dynamic>{
      'id': instance.tagID,
      'name': instance.tagName,
    };

UserTagHolder _$UserTagHolderFromJson(Map<String, dynamic> json) =>
    UserTagHolder(
      holderID: (json['id'] as num?)?.toInt(),
      holderName: json['name'] as String?,
      holderTags: (json['tags'] as List<dynamic>?)
          ?.map((e) => UserTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserTagHolderToJson(UserTagHolder instance) =>
    <String, dynamic>{
      'id': instance.holderID,
      'name': instance.holderName,
      'tags': instance.holderTags,
    };
