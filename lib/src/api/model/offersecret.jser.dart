// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offersecret.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$OffersecretSerializer implements Serializer<Offersecret> {
  @override
  Map<String, dynamic> toMap(Offersecret model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'secret', model.secret);
    return ret;
  }

  @override
  Offersecret fromMap(Map map) {
    if (map == null) return null;
    final obj = Offersecret();
    obj.secret = map['secret'] as String;
    return obj;
  }
}
