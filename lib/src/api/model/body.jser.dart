// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$BodySerializer implements Serializer<Body> {
  @override
  Map<String, dynamic> toMap(Body model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'str_id', model.strId);
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'short_description', model.shortDescription);
    setMapValue(ret, 'website_url', model.websiteUrl);
    setMapValue(ret, 'image_url', model.imageUrl);
    setMapValue(ret, 'cover_url', model.coverUrl);
    return ret;
  }

  @override
  Body fromMap(Map map) {
    if (map == null) return null;
    final obj = new Body();
    obj.id = map['id'] as String;
    obj.strId = map['str_id'] as String;
    obj.name = map['name'] as String;
    obj.shortDescription = map['short_description'] as String;
    obj.websiteUrl = map['website_url'] as String;
    obj.imageUrl = map['image_url'] as String;
    obj.coverUrl = map['cover_url'] as String;
    return obj;
  }
}
