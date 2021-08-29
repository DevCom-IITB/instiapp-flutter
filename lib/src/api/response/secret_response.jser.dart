// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$secret_responseSerializer
    implements Serializer<secret_response> {
  @override
  Map<String, dynamic> toMap(secret_response model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'message', model.message);
    return ret;
  }

  @override
  secret_response fromMap(Map map) {
    if (map == null) return null;
    final obj = secret_response();
    obj.message = map['message'] as String;
    return obj;
  }
}
