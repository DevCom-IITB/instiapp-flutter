// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: avoid_returning_this
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_new
// ignore_for_file: test_types_in_equals

Serializer<Hostel> _$hostelSerializer = new _$HostelSerializer();
Serializer<HostelMess> _$hostelMessSerializer = new _$HostelMessSerializer();

class _$HostelSerializer implements StructuredSerializer<Hostel> {
  @override
  final Iterable<Type> types = const [Hostel, _$Hostel];
  @override
  final String wireName = 'Hostel';

  @override
  Iterable serialize(Serializers serializers, Hostel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'short_name',
      serializers.serialize(object.short_name,
          specifiedType: const FullType(String)),
      'long_name',
      serializers.serialize(object.long_name,
          specifiedType: const FullType(String)),
      'mess',
      serializers.serialize(object.mess,
          specifiedType:
              const FullType(BuiltList, const [const FullType(HostelMess)])),
    ];

    return result;
  }

  @override
  Hostel deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new HostelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'short_name':
          result.short_name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'long_name':
          result.long_name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'mess':
          result.mess.replace(serializers.deserialize(value,
              specifiedType: const FullType(
                  BuiltList, const [const FullType(HostelMess)])) as BuiltList);
          break;
      }
    }

    return result.build();
  }
}

class _$HostelMessSerializer implements StructuredSerializer<HostelMess> {
  @override
  final Iterable<Type> types = const [HostelMess, _$HostelMess];
  @override
  final String wireName = 'HostelMess';

  @override
  Iterable serialize(Serializers serializers, HostelMess object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'day',
      serializers.serialize(object.day, specifiedType: const FullType(int)),
      'breakfast',
      serializers.serialize(object.breakfast,
          specifiedType: const FullType(String)),
      'lunch',
      serializers.serialize(object.lunch,
          specifiedType: const FullType(String)),
      'snacks',
      serializers.serialize(object.snacks,
          specifiedType: const FullType(String)),
      'dinner',
      serializers.serialize(object.dinner,
          specifiedType: const FullType(String)),
      'hostel',
      serializers.serialize(object.hostel,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  HostelMess deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new HostelMessBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'day':
          result.day = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'breakfast':
          result.breakfast = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'lunch':
          result.lunch = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'snacks':
          result.snacks = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'dinner':
          result.dinner = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'hostel':
          result.hostel = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Hostel extends Hostel {
  @override
  final String id;
  @override
  final String name;
  @override
  final String short_name;
  @override
  final String long_name;
  @override
  final BuiltList<HostelMess> mess;

  factory _$Hostel([void updates(HostelBuilder b)]) =>
      (new HostelBuilder()..update(updates)).build();

  _$Hostel._({this.id, this.name, this.short_name, this.long_name, this.mess})
      : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('Hostel', 'id');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('Hostel', 'name');
    }
    if (short_name == null) {
      throw new BuiltValueNullFieldError('Hostel', 'short_name');
    }
    if (long_name == null) {
      throw new BuiltValueNullFieldError('Hostel', 'long_name');
    }
    if (mess == null) {
      throw new BuiltValueNullFieldError('Hostel', 'mess');
    }
  }

  @override
  Hostel rebuild(void updates(HostelBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  HostelBuilder toBuilder() => new HostelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Hostel &&
        id == other.id &&
        name == other.name &&
        short_name == other.short_name &&
        long_name == other.long_name &&
        mess == other.mess;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, id.hashCode), name.hashCode), short_name.hashCode),
            long_name.hashCode),
        mess.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Hostel')
          ..add('id', id)
          ..add('name', name)
          ..add('short_name', short_name)
          ..add('long_name', long_name)
          ..add('mess', mess))
        .toString();
  }
}

class HostelBuilder implements Builder<Hostel, HostelBuilder> {
  _$Hostel _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _short_name;
  String get short_name => _$this._short_name;
  set short_name(String short_name) => _$this._short_name = short_name;

  String _long_name;
  String get long_name => _$this._long_name;
  set long_name(String long_name) => _$this._long_name = long_name;

  ListBuilder<HostelMess> _mess;
  ListBuilder<HostelMess> get mess =>
      _$this._mess ??= new ListBuilder<HostelMess>();
  set mess(ListBuilder<HostelMess> mess) => _$this._mess = mess;

  HostelBuilder();

  HostelBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _short_name = _$v.short_name;
      _long_name = _$v.long_name;
      _mess = _$v.mess?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Hostel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Hostel;
  }

  @override
  void update(void updates(HostelBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Hostel build() {
    _$Hostel _$result;
    try {
      _$result = _$v ??
          new _$Hostel._(
              id: id,
              name: name,
              short_name: short_name,
              long_name: long_name,
              mess: mess.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'mess';
        mess.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Hostel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$HostelMess extends HostelMess {
  @override
  final String id;
  @override
  final int day;
  @override
  final String breakfast;
  @override
  final String lunch;
  @override
  final String snacks;
  @override
  final String dinner;
  @override
  final String hostel;

  factory _$HostelMess([void updates(HostelMessBuilder b)]) =>
      (new HostelMessBuilder()..update(updates)).build();

  _$HostelMess._(
      {this.id,
      this.day,
      this.breakfast,
      this.lunch,
      this.snacks,
      this.dinner,
      this.hostel})
      : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'id');
    }
    if (day == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'day');
    }
    if (breakfast == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'breakfast');
    }
    if (lunch == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'lunch');
    }
    if (snacks == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'snacks');
    }
    if (dinner == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'dinner');
    }
    if (hostel == null) {
      throw new BuiltValueNullFieldError('HostelMess', 'hostel');
    }
  }

  @override
  HostelMess rebuild(void updates(HostelMessBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  HostelMessBuilder toBuilder() => new HostelMessBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HostelMess &&
        id == other.id &&
        day == other.day &&
        breakfast == other.breakfast &&
        lunch == other.lunch &&
        snacks == other.snacks &&
        dinner == other.dinner &&
        hostel == other.hostel;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, id.hashCode), day.hashCode),
                        breakfast.hashCode),
                    lunch.hashCode),
                snacks.hashCode),
            dinner.hashCode),
        hostel.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('HostelMess')
          ..add('id', id)
          ..add('day', day)
          ..add('breakfast', breakfast)
          ..add('lunch', lunch)
          ..add('snacks', snacks)
          ..add('dinner', dinner)
          ..add('hostel', hostel))
        .toString();
  }
}

class HostelMessBuilder implements Builder<HostelMess, HostelMessBuilder> {
  _$HostelMess _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _day;
  int get day => _$this._day;
  set day(int day) => _$this._day = day;

  String _breakfast;
  String get breakfast => _$this._breakfast;
  set breakfast(String breakfast) => _$this._breakfast = breakfast;

  String _lunch;
  String get lunch => _$this._lunch;
  set lunch(String lunch) => _$this._lunch = lunch;

  String _snacks;
  String get snacks => _$this._snacks;
  set snacks(String snacks) => _$this._snacks = snacks;

  String _dinner;
  String get dinner => _$this._dinner;
  set dinner(String dinner) => _$this._dinner = dinner;

  String _hostel;
  String get hostel => _$this._hostel;
  set hostel(String hostel) => _$this._hostel = hostel;

  HostelMessBuilder();

  HostelMessBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _day = _$v.day;
      _breakfast = _$v.breakfast;
      _lunch = _$v.lunch;
      _snacks = _$v.snacks;
      _dinner = _$v.dinner;
      _hostel = _$v.hostel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HostelMess other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$HostelMess;
  }

  @override
  void update(void updates(HostelMessBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$HostelMess build() {
    final _$result = _$v ??
        new _$HostelMess._(
            id: id,
            day: day,
            breakfast: breakfast,
            lunch: lunch,
            snacks: snacks,
            dinner: dinner,
            hostel: hostel);
    replace(_$result);
    return _$result;
  }
}
