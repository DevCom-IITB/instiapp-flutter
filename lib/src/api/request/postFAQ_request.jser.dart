// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postFAQ_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$PostFAQRequestSerializer
    implements Serializer<PostFAQRequest> {
  @override
  Map<String, dynamic> toMap(PostFAQRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'question', model.question);
    setMapValue(ret, 'category', model.category);
    return ret;
  }

  @override
  PostFAQRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = PostFAQRequest();
    obj.question = map['question'] as String;
    obj.category = map['category'] as String;
    return obj;
  }
}
