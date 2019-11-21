library shared_pref_navigatin_saver;

import 'package:flutter/widgets.dart';
import 'package:navigation_saver/navigation_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef RoutesToStringConverter = Future<String> Function(Iterable<RouteSettings> routes);
typedef StringToRoutesConverter = Future<Iterable<RouteSettings>> Function(String routesAsString);

const String _keyRoutes = 'SharedPrefNavigationSaver_routes';
const String _keySaveTime = 'SharedPrefNavigationSaver_saveTime';

class SharedPrefNavigationSaver extends NavigationSaver {
  SharedPrefNavigationSaver(
    RoutesToStringConverter routesToStringConverter,
    StringToRoutesConverter stringToRoutesConverter, {
    Duration maximumDurationBetweenRestoration = const Duration(minutes: 5),
    String defaultNavigationRoute,
  }) : super(
          (Iterable<RouteSettings> activeRoutes) async {
            try {
              if (activeRoutes.isEmpty) return;

              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString(_keyRoutes, await routesToStringConverter(activeRoutes));
              await prefs.setInt(_keySaveTime, DateTime.now().toUtc().millisecondsSinceEpoch);
            } catch (e) {
              print(e);
            }
          },
          () async {
            try {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              final int lastSavedTimeInMillis = prefs.getInt(_keySaveTime);

              final DateTime nowTime = DateTime.now().toUtc();
              DateTime lastSavedTime = nowTime;
              if (null != lastSavedTimeInMillis) {
                lastSavedTime = DateTime.fromMillisecondsSinceEpoch(lastSavedTimeInMillis);
              }
              final Duration diffTime = nowTime.difference(lastSavedTime);
              if (null == maximumDurationBetweenRestoration ||
                  diffTime < maximumDurationBetweenRestoration) {
                final String routesAsString = prefs.getString(_keyRoutes);
                if (null == routesAsString || routesAsString.isEmpty) return <RouteSettings>[];
                return await stringToRoutesConverter(routesAsString);
              }
            } catch (e) {
              print(e);
            }
            return <RouteSettings>[];
          },
          defaultNavigationRoute: defaultNavigationRoute,
        );
}
