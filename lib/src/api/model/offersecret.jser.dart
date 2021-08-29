// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offersecret.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$offersecretSerializer implements Serializer<offersecret> {
  @override
  Map<String, dynamic> toMap(offersecret model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'secret', model.secret);
    return ret;
  }

  @override
  offersecret fromMap(Map map) {
    if (map == null) return null;
    final obj = offersecret();
    obj.secret = map['secret'] as String;
    return obj;
  }
}
