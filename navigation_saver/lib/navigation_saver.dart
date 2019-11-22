library navigation_saver;

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

typedef NavigationRoutesSaver = Future<void> Function(
    Iterable<RouteSettings> activeRoutes);
typedef NavigationRoutesRestorer = Future<Iterable<RouteSettings>> Function();

typedef WidgetRouteGenerator = Route<dynamic> Function(
    RouteSettings routeSettings);
typedef NavigationSaverRouteFactory = Route<dynamic> Function(
  RouteSettings settings, {
  NextPageInfo nextPageInfo,
});

class NavigationSaver extends NavigatorObserver {
  NavigationSaver(
    this._navigationRoutesSaver,
    this._navigationRoutesRestorer, {
    String defaultNavigationRoute,
  })  : assert(null != _navigationRoutesSaver,
            'navigationRoutesSaver should not ne null'),
        assert(null != _navigationRoutesRestorer,
            'navigationRoutesRestorer should not ne null'),
        this._defaultNavigationRoute =
            defaultNavigationRoute ?? Navigator.defaultRouteName;

  static final String restoreRouteName = 'navigationSaverRestore';

  final NavigationRoutesSaver _navigationRoutesSaver;
  final NavigationRoutesRestorer _navigationRoutesRestorer;

  final String _defaultNavigationRoute;

  int _routesVersion = 0;
  final List<Route<dynamic>> _activeRoutes = <Route<dynamic>>[];

  Future<void> restorePreviousRoutes(BuildContext context) async {
    final Iterable<RouteSettings> routeSettings =
        await _navigationRoutesRestorer();
    if (null == routeSettings) {
      throw ArgumentError.notNull('routeSettings');
    }

    _restoreRoutesInternal(context, routeSettings.toList());
  }

  Route<dynamic> onGenerateRoute(
    RouteSettings routeSettings,
    NavigationSaverRouteFactory routeFactory, {
    WidgetBuilder restoreRouteWidgetBuilder,
  }) {
    if (routeSettings.name == NavigationSaver.restoreRouteName) {
      final WidgetBuilder builder =
          (BuildContext context) => NavigationRestorationWidget(
                navigationSaver: this,
                child: null == restoreRouteWidgetBuilder
                    ? Container()
                    : restoreRouteWidgetBuilder(context),
              );
      if (Platform.isIOS) {
        return CupertinoPageRoute(builder: builder, settings: routeSettings);
      } else {
        return MaterialPageRoute(builder: builder, settings: routeSettings);
      }
    } else {
      final routeArguments = routeSettings.arguments;
      dynamic realArguments = routeArguments;
      NextPageInfo nextPageInfo;
      if (routeArguments is RestoredArguments) {
        realArguments = routeArguments.arguments;
        nextPageInfo = routeArguments.nextPageInfo;
      }
      return routeFactory(
        RouteSettings(
          name: routeSettings.name,
          arguments: realArguments,
          isInitialRoute: routeSettings.isInitialRoute,
        ),
        nextPageInfo: nextPageInfo,
      );
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    _activeRoutes.remove(oldRoute);
    _activeRoutes.add(newRoute);
    _routesVersion++;
    _saveRoutes();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    _activeRoutes.remove(route);
    _routesVersion++;
    _saveRoutes();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    _activeRoutes.remove(route);
    _routesVersion++;
    _saveRoutes();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    _activeRoutes.add(route);
    _routesVersion++;
    _saveRoutes();
  }

  void _saveRoutes() {
    final int localRoutesVersion = _routesVersion;
    final List<RouteSettings> localActiveRouteSettings = _activeRoutes
        .map((Route route) => route.settings)
        .where((RouteSettings settings) => settings.name != null)
        .where((RouteSettings settings) => settings.name != restoreRouteName)
        .map((RouteSettings settings) {
      if (settings.arguments is RestoredArguments) {
        return RouteSettings(
          name: settings.name,
          isInitialRoute: settings.isInitialRoute,
          arguments: (settings.arguments as RestoredArguments).arguments,
        );
      } else {
        return settings;
      }
    }).toList();
    Future(() async {
      await Future.delayed(Duration(milliseconds: 500));
      if (localRoutesVersion == _routesVersion) {
        await _navigationRoutesSaver(localActiveRouteSettings);
      }
    });
  }

  void _restoreRoutesInternal(
      BuildContext context, List<RouteSettings> routeSettings) {
    final NavigatorState navigator = Navigator.of(context);
    while (navigator.canPop()) {
      navigator.pop();
    }
    if (routeSettings.isEmpty) {
      unawaited(navigator.pushReplacementNamed(_defaultNavigationRoute));
    } else {
      var prevRouteCompleter;
      for (int i = 0; i < routeSettings.length; ++i) {
        final RouteSettings routeSetting = routeSettings[i];
        final RouteSettings nextRouteSetting =
            (i < routeSettings.length - 1) ? routeSettings[i + 1] : null;
        Completer currentRouteCompleter;
        if (nextRouteSetting != null) {
          currentRouteCompleter = Completer();
        }
        final RestoredArguments arguments = RestoredArguments(
          null == nextRouteSetting
              ? null
              : NextPageInfo(
                  nextRouteSetting.name, currentRouteCompleter.future),
          routeSetting.arguments,
        );
        if (i == 0) {
          navigator.pushReplacementNamed(routeSetting.name,
              arguments: arguments);
        } else {
          _waitForTheResultAndPublishAsLost(
            () => navigator.pushNamed(routeSetting.name, arguments: arguments),
            prevRouteCompleter,
          );
        }
        if (null != currentRouteCompleter) {
          prevRouteCompleter = currentRouteCompleter;
        }
      }
    }
  }

  Future<void> _waitForTheResultAndPublishAsLost(
    Future<dynamic> Function() navigationAction,
    Completer completer,
  ) async {
    final result = await navigationAction();
    completer?.complete(result);
  }
}

class NavigationRestorationWidget extends StatefulWidget {
  NavigationRestorationWidget({
    @required this.navigationSaver,
    @required this.child,
  });

  final NavigationSaver navigationSaver;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _NavigationRestorationState();
}

@immutable
class RestoredArguments {
  const RestoredArguments(
    this.nextPageInfo,
    this.arguments,
  );

  final NextPageInfo nextPageInfo;
  final Object arguments;
}

@immutable
class NextPageInfo {
  const NextPageInfo(
    this.routeName,
    this.resultFuture,
  );

  final String routeName;
  final Future resultFuture;
}

class _NavigationRestorationState extends State<NavigationRestorationWidget> {
  @override
  void initState() {
    super.initState();

    widget.navigationSaver.restorePreviousRoutes(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
