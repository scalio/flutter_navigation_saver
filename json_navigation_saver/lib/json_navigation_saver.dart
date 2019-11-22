library json_navigation_saver;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:json_annotation/json_annotation.dart';
import 'package:navigation_saver/navigation_saver.dart';

part 'json_navigation_saver.g.dart';

typedef ArgumentsFromJson = Object Function(Map<String, dynamic> argumentsJson);
typedef ArgumentsToJson = Map<String, dynamic> Function(Object argument);

@JsonSerializable(
  nullable: false,
  explicitToJson: true,
)
class RoutesInfo {
  RoutesInfo({
    @required this.routes,
  });

  factory RoutesInfo.fromJson(Map<String, dynamic> json) =>
      _$RoutesInfoFromJson(json);

  final List<NavigatorRouteSettings> routes;

  Map<String, dynamic> toJson() => _$RoutesInfoToJson(this);
}

@JsonSerializable(
  nullable: false,
  explicitToJson: true,
)
class NavigatorRouteSettings {
  NavigatorRouteSettings({
    @required this.name,
    @required this.isInitialRoute,
    this.arguments,
  });

  factory NavigatorRouteSettings.fromJson(Map<String, dynamic> json) =>
      _$NavigatorRouteSettingsFromJson(json);

  factory NavigatorRouteSettings.fromSettings(
          widgets.RouteSettings routeSettings) =>
      NavigatorRouteSettings(
        name: routeSettings.name,
        isInitialRoute: routeSettings.isInitialRoute,
        arguments: (routeSettings.arguments is RestoredArguments)
            ? (routeSettings.arguments as RestoredArguments).arguments
            : routeSettings.arguments,
      );

  final String name;
  final bool isInitialRoute;
  final Map<String, dynamic> arguments;

  Map<String, dynamic> toJson() => _$NavigatorRouteSettingsToJson(this);

  widgets.RouteSettings toRouteSettings() => widgets.RouteSettings(
        name: name,
        isInitialRoute: isInitialRoute,
        arguments: arguments,
      );
}

Map<String, dynamic> serializeRoutes(
  Iterable<widgets.RouteSettings> routes,
) =>
    RoutesInfo(routes: convertToWidgetRouteSettings(routes).toList()).toJson();

Iterable<NavigatorRouteSettings> convertToWidgetRouteSettings(
  Iterable<widgets.RouteSettings> routes,
) =>
    routes.map(
      (widgets.RouteSettings routeSettings) =>
          NavigatorRouteSettings.fromSettings(routeSettings),
    );

Iterable<widgets.RouteSettings> deserializeRoutes(
  Map<String, dynamic> routesInfoJson,
) =>
    convertToNavigatorRouteSettings(RoutesInfo.fromJson(routesInfoJson).routes);

Iterable<widgets.RouteSettings> convertToNavigatorRouteSettings(
  Iterable<NavigatorRouteSettings> routes,
) =>
    routes.map(
      (NavigatorRouteSettings routeSettings) => routeSettings.toRouteSettings(),
    );
