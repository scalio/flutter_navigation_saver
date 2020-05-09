import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:navigation_saver/navigation_saver.dart';

part 'navigation_saver_routes_info.g.dart';

abstract class RoutesInfo implements Built<RoutesInfo, RoutesInfoBuilder> {
  RoutesInfo._();

  factory RoutesInfo([
    void Function(RoutesInfoBuilder) updates,
  ]) = _$RoutesInfo;

  static Serializer<RoutesInfo> get serializer => _$routesInfoSerializer;

  BuiltList<NavigatorRouteSettings> get routes;
}

abstract class NavigatorRouteSettings
    implements Built<NavigatorRouteSettings, NavigatorRouteSettingsBuilder> {
  NavigatorRouteSettings._();

  factory NavigatorRouteSettings([
    void Function(NavigatorRouteSettingsBuilder) updates,
  ]) = _$NavigatorRouteSettings;

  factory NavigatorRouteSettings.fromSettings(
          widgets.RouteSettings routeSettings) =>
      NavigatorRouteSettings(
        (b) => b
          ..name = routeSettings.name
          ..arguments = (routeSettings.arguments is RestoredArguments)
              ? (routeSettings.arguments as RestoredArguments).arguments
              : routeSettings.arguments,
      );

  static Serializer<NavigatorRouteSettings> get serializer =>
      _$navigatorRouteSettingsSerializer;

  String get name;

  @nullable
  Built get arguments;

  widgets.RouteSettings toRouteSettings() => widgets.RouteSettings(
        name: name,
        arguments: arguments,
      );
}

Object serializeRoutes(
  Serializers serializers,
  Iterable<widgets.RouteSettings> routes,
) =>
    serializers.serializeWith(
      RoutesInfo.serializer,
      RoutesInfo(
        (b) => b
          ..routes = ListBuilder<NavigatorRouteSettings>(
              convertToWidgetRouteSettings(routes)),
      ),
    );

Iterable<NavigatorRouteSettings> convertToWidgetRouteSettings(
  Iterable<widgets.RouteSettings> routes,
) =>
    routes.map(
      (widgets.RouteSettings routeSettings) =>
          NavigatorRouteSettings.fromSettings(routeSettings),
    );

Iterable<widgets.RouteSettings> deserializeRoutes(
  Serializers serializers,
  dynamic routes,
) =>
    convertToNavigatorRouteSettings(
      serializers
          .deserializeWith(
            RoutesInfo.serializer,
            routes,
          )
          .routes,
    );

Iterable<widgets.RouteSettings> convertToNavigatorRouteSettings(
  Iterable<NavigatorRouteSettings> routes,
) =>
    routes.map(
      (NavigatorRouteSettings routeSettings) => routeSettings.toRouteSettings(),
    );
