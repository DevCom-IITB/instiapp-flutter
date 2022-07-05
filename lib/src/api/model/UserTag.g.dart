part of 'UserTag.dart';

UserTag _$UserTagFromJson(Map<String, dynamic> json) => UserTag(
tagID: json['id'] as int,
  tagName: json['name'] as String
);

Map<String, dynamic> _$UserTagToJson(UserTag instance) => <String, dynamic>{
  'id': instance.tagID,
  'name': instance.tagName,
};
UserTagHolder _$UserTagHolderFromJson(Map<String, dynamic> json) => UserTagHolder(
    holderID: json['id'] as int,
    holderName: json['name'] as String,
    holderTags: (json['tags'] as List<dynamic>).map((i)=>UserTag.fromJson(i as Map<String, dynamic>)).toList()
);

Map<String, dynamic> _$UserTagHolderToJson(UserTagHolder instance) => <String, dynamic>{
  'id': instance.holderID,
  'name': instance.holderName,
  'tags':instance.holderTags
};
