// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_saver_routes_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<RoutesInfo> _$routesInfoSerializer = new _$RoutesInfoSerializer();
Serializer<NavigatorRouteSettings> _$navigatorRouteSettingsSerializer =
    new _$NavigatorRouteSettingsSerializer();

class _$RoutesInfoSerializer implements StructuredSerializer<RoutesInfo> {
  @override
  final Iterable<Type> types = const [RoutesInfo, _$RoutesInfo];
  @override
  final String wireName = 'RoutesInfo';

  @override
  Iterable<Object> serialize(Serializers serializers, RoutesInfo object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'routes',
      serializers.serialize(object.routes,
          specifiedType: const FullType(
              BuiltList, const [const FullType(NavigatorRouteSettings)])),
    ];

    return result;
  }

  @override
  RoutesInfo deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new RoutesInfoBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'routes':
          result.routes.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(NavigatorRouteSettings)
              ])) as BuiltList<dynamic>);
          break;
      }
    }

    return result.build();
  }
}

class _$NavigatorRouteSettingsSerializer
    implements StructuredSerializer<NavigatorRouteSettings> {
  @override
  final Iterable<Type> types = const [
    NavigatorRouteSettings,
    _$NavigatorRouteSettings
  ];
  @override
  final String wireName = 'NavigatorRouteSettings';

  @override
  Iterable<Object> serialize(
      Serializers serializers, NavigatorRouteSettings object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'isInitialRoute',
      serializers.serialize(object.isInitialRoute,
          specifiedType: const FullType(bool)),
    ];
    if (object.arguments != null) {
      result
        ..add('arguments')
        ..add(serializers.serialize(object.arguments,
            specifiedType: const FullType(Built,
                const [const FullType(Built), const FullType(Builder)])));
    }
    return result;
  }

  @override
  NavigatorRouteSettings deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new NavigatorRouteSettingsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'isInitialRoute':
          result.isInitialRoute = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'arguments':
          result.arguments = serializers.deserialize(value,
              specifiedType: const FullType(Built, const [
                const FullType(Built),
                const FullType(Builder)
              ])) as Built<Built, Builder>;
          break;
      }
    }

    return result.build();
  }
}

class _$RoutesInfo extends RoutesInfo {
  @override
  final BuiltList<NavigatorRouteSettings> routes;

  factory _$RoutesInfo([void Function(RoutesInfoBuilder) updates]) =>
      (new RoutesInfoBuilder()..update(updates)).build();

  _$RoutesInfo._({this.routes}) : super._() {
    if (routes == null) {
      throw new BuiltValueNullFieldError('RoutesInfo', 'routes');
    }
  }

  @override
  RoutesInfo rebuild(void Function(RoutesInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesInfoBuilder toBuilder() => new RoutesInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesInfo && routes == other.routes;
  }

  @override
  int get hashCode {
    return $jf($jc(0, routes.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('RoutesInfo')..add('routes', routes))
        .toString();
  }
}

class RoutesInfoBuilder implements Builder<RoutesInfo, RoutesInfoBuilder> {
  _$RoutesInfo _$v;

  ListBuilder<NavigatorRouteSettings> _routes;
  ListBuilder<NavigatorRouteSettings> get routes =>
      _$this._routes ??= new ListBuilder<NavigatorRouteSettings>();
  set routes(ListBuilder<NavigatorRouteSettings> routes) =>
      _$this._routes = routes;

  RoutesInfoBuilder();

  RoutesInfoBuilder get _$this {
    if (_$v != null) {
      _routes = _$v.routes?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesInfo other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$RoutesInfo;
  }

  @override
  void update(void Function(RoutesInfoBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$RoutesInfo build() {
    _$RoutesInfo _$result;
    try {
      _$result = _$v ?? new _$RoutesInfo._(routes: routes.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'routes';
        routes.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'RoutesInfo', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$NavigatorRouteSettings extends NavigatorRouteSettings {
  @override
  final String name;
  @override
  final bool isInitialRoute;
  @override
  final Built<Built, Builder> arguments;

  factory _$NavigatorRouteSettings(
          [void Function(NavigatorRouteSettingsBuilder) updates]) =>
      (new NavigatorRouteSettingsBuilder()..update(updates)).build();

  _$NavigatorRouteSettings._({this.name, this.isInitialRoute, this.arguments})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('NavigatorRouteSettings', 'name');
    }
    if (isInitialRoute == null) {
      throw new BuiltValueNullFieldError(
          'NavigatorRouteSettings', 'isInitialRoute');
    }
  }

  @override
  NavigatorRouteSettings rebuild(
          void Function(NavigatorRouteSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NavigatorRouteSettingsBuilder toBuilder() =>
      new NavigatorRouteSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NavigatorRouteSettings &&
        name == other.name &&
        isInitialRoute == other.isInitialRoute &&
        arguments == other.arguments;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, name.hashCode), isInitialRoute.hashCode),
        arguments.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('NavigatorRouteSettings')
          ..add('name', name)
          ..add('isInitialRoute', isInitialRoute)
          ..add('arguments', arguments))
        .toString();
  }
}

class NavigatorRouteSettingsBuilder
    implements Builder<NavigatorRouteSettings, NavigatorRouteSettingsBuilder> {
  _$NavigatorRouteSettings _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  bool _isInitialRoute;
  bool get isInitialRoute => _$this._isInitialRoute;
  set isInitialRoute(bool isInitialRoute) =>
      _$this._isInitialRoute = isInitialRoute;

  Built<Built, Builder> _arguments;
  Built<Built, Builder> get arguments => _$this._arguments;
  set arguments(Built<Built, Builder> arguments) =>
      _$this._arguments = arguments;

  NavigatorRouteSettingsBuilder();

  NavigatorRouteSettingsBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _isInitialRoute = _$v.isInitialRoute;
      _arguments = _$v.arguments;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NavigatorRouteSettings other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$NavigatorRouteSettings;
  }

  @override
  void update(void Function(NavigatorRouteSettingsBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$NavigatorRouteSettings build() {
    final _$result = _$v ??
        new _$NavigatorRouteSettings._(
            name: name, isInitialRoute: isInitialRoute, arguments: arguments);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
