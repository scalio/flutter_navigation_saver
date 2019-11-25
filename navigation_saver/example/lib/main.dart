import 'package:example/home/home_page.dart';
import 'package:example/home/home_page_arguments.dart';
import 'package:flutter/material.dart';
import 'package:navigation_saver/navigation_saver.dart';

void main() {
  Iterable<RouteSettings> savedRoutes = <RouteSettings>[];
  final NavigationSaver _navigatorSaver = NavigationSaver(
    (Iterable<RouteSettings> routes) async => savedRoutes = routes,
    () async => savedRoutes,
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
      onGenerateRoute: (RouteSettings routeSettings) =>
          _navigationSaver.onGenerateRoute(
        routeSettings,
        (
          RouteSettings settings, {
          NextPageInfo nextPageInfo,
        }) =>
            MaterialPageRoute(
          builder: (BuildContext context) => MyHomePage(
            initialCounter: settings.arguments is MyHomePageArguments
                ? (settings.arguments as MyHomePageArguments).deepIndex
                : 0,
            nextPageInfo: nextPageInfo,
          ),
          settings: routeSettings,
        ),
      ),
      navigatorObservers: [_navigationSaver],
    );
  }
}
