import 'dart:convert';

import 'package:example/home/home_page.dart';
import 'package:example/home/home_page_arguments.dart';
import 'package:flutter/material.dart';
import 'package:json_navigation_saver/json_navigation_saver.dart';
import 'package:navigation_saver/navigation_saver.dart';
import 'package:shared_pref_navigation_saver/shared_pref_navigatin_saver.dart';

void main() {
  final NavigationSaver _navigatorSaver = SharedPrefNavigationSaver(
    (Iterable<RouteSettings> routes) async => json.encode(serializeRoutes(routes)),
    (String routesAsString) async => deserializeRoutes(json.decode(routesAsString)),
  );

  runApp(MyApp(_navigatorSaver));
}

class MyApp extends StatelessWidget {
  MyApp(this._navigationSaver);

  final NavigationSaver _navigationSaver;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: NavigationSaver.restoreRouteName,
      onGenerateRoute: (RouteSettings routeSettings) => _navigationSaver.onGenerateRoute(
        routeSettings,
        (
          RouteSettings settings,
          String routeName,
          Object routeArguments, {
          NextPageInfo nextPageInfo,
        }) =>
            MaterialPageRoute(
          builder: (BuildContext context) => MyHomePage(
            initialCounter:
                routeArguments is Map ? MyHomePageArguments.fromJson(routeArguments).deepIndex : 0,
            nextPageInfo: nextPageInfo,
          ),
          settings: routeSettings,
        ),
      ),
      navigatorObservers: [_navigationSaver],
    );
  }
}
