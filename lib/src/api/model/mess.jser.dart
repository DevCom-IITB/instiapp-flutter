// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$HostelSerializer implements Serializer<Hostel> {
  Serializer<HostelMess> __hostelMessSerializer;
  Serializer<HostelMess> get _hostelMessSerializer =>
      __hostelMessSerializer ??= new HostelMessSerializer();
  @override
  Map<String, dynamic> toMap(Hostel model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'short_name', model.shortName);
    setMapValue(ret, 'long_name', model.longName);
    setMapValue(
        ret,
        'mess',
        codeIterable(model.mess,
            (val) => _hostelMessSerializer.toMap(val as HostelMess)));
    return ret;
  }

  @override
  Hostel fromMap(Map map) {
    if (map == null) return null;
    final obj = new Hostel();
    obj.id = map['id'] as String;
    obj.name = map['name'] as String;
    obj.shortName = map['short_name'] as String;
    obj.longName = map['long_name'] as String;
    obj.mess = codeIterable<HostelMess>(map['mess'] as Iterable,
        (val) => _hostelMessSerializer.fromMap(val as Map));
    return obj;
  }
}

abstract class _$HostelMessSerializer implements Serializer<HostelMess> {
  @override
  Map<String, dynamic> toMap(HostelMess model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'day', model.day);
    setMapValue(ret, 'breakfast', model.breakfast);
    setMapValue(ret, 'lunch', model.lunch);
    setMapValue(ret, 'snacks', model.snacks);
    setMapValue(ret, 'dinner', model.dinner);
    setMapValue(ret, 'hostel', model.hostel);
    return ret;
  }

  @override
  HostelMess fromMap(Map map) {
    if (map == null) return null;
    final obj = new HostelMess();
    obj.id = map['id'] as String;
    obj.day = map['day'] as int;
    obj.breakfast = map['breakfast'] as String;
    obj.lunch = map['lunch'] as String;
    obj.snacks = map['snacks'] as String;
    obj.dinner = map['dinner'] as String;
    obj.hostel = map['hostel'] as String;
    return obj;
  }
}
