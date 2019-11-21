// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page_arguments.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MyHomePageArguments> _$myHomePageArgumentsSerializer =
    new _$MyHomePageArgumentsSerializer();

class _$MyHomePageArgumentsSerializer
    implements StructuredSerializer<MyHomePageArguments> {
  @override
  final Iterable<Type> types = const [
    MyHomePageArguments,
    _$MyHomePageArguments
  ];
  @override
  final String wireName = 'MyHomePageArguments';

  @override
  Iterable<Object> serialize(
      Serializers serializers, MyHomePageArguments object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'deepIndex',
      serializers.serialize(object.deepIndex,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  MyHomePageArguments deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new MyHomePageArgumentsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'deepIndex':
          result.deepIndex = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$MyHomePageArguments extends MyHomePageArguments {
  @override
  final int deepIndex;

  factory _$MyHomePageArguments(
          [void Function(MyHomePageArgumentsBuilder) updates]) =>
      (new MyHomePageArgumentsBuilder()..update(updates)).build();

  _$MyHomePageArguments._({this.deepIndex}) : super._() {
    if (deepIndex == null) {
      throw new BuiltValueNullFieldError('MyHomePageArguments', 'deepIndex');
    }
  }

  @override
  MyHomePageArguments rebuild(
          void Function(MyHomePageArgumentsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MyHomePageArgumentsBuilder toBuilder() =>
      new MyHomePageArgumentsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MyHomePageArguments && deepIndex == other.deepIndex;
  }

  @override
  int get hashCode {
    return $jf($jc(0, deepIndex.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('MyHomePageArguments')
          ..add('deepIndex', deepIndex))
        .toString();
  }
}

class MyHomePageArgumentsBuilder
    implements Builder<MyHomePageArguments, MyHomePageArgumentsBuilder> {
  _$MyHomePageArguments _$v;

  int _deepIndex;
  int get deepIndex => _$this._deepIndex;
  set deepIndex(int deepIndex) => _$this._deepIndex = deepIndex;

  MyHomePageArgumentsBuilder();

  MyHomePageArgumentsBuilder get _$this {
    if (_$v != null) {
      _deepIndex = _$v.deepIndex;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MyHomePageArguments other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$MyHomePageArguments;
  }

  @override
  void update(void Function(MyHomePageArgumentsBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$MyHomePageArguments build() {
    final _$result = _$v ?? new _$MyHomePageArguments._(deepIndex: deepIndex);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
