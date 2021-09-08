// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_response.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$SecretResponseSerializer
    implements Serializer<SecretResponse> {
  @override
  Map<String, dynamic> toMap(SecretResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'message', model.message);
    return ret;
  }

  @override
  SecretResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = SecretResponse();
    obj.message = map['message'] as String;
    return obj;
  }
}
