// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_create_request.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$CommentCreateRequestSerializer
    implements Serializer<CommentCreateRequest> {
  @override
  Map<String, dynamic> toMap(CommentCreateRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'text', model.text);
    return ret;
  }

  @override
  CommentCreateRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = CommentCreateRequest();
    obj.text = map['text'] as String;
    return obj;
  }
}
