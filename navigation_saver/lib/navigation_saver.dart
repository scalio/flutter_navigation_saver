library navigation_saver;

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

/// will be called to save passed routes
typedef NavigationRoutesSaver = Future<void> Function(
    Iterable<RouteSettings> activeRoutes);

/// will be called to restore previous routes
typedef NavigationRoutesRestorer = Future<Iterable<RouteSettings>> Function();

/// will be called to create application route from settings
typedef NavigationSaverRouteFactory = Route<dynamic> Function(
  RouteSettings settings, {
  NextPageInfo nextPageInfo,
});

///
/// This is the core class of the navigation saver logic.
///
/// The main functions of this class:
/// 1. Observe all route changes and fire save event with appropriate route settings.
/// 2. Restore all the navigation stack after the command. See [restorePreviousRoutes].
/// 3. Have helper method to extract library route settings to the application level route settings. See [onGenerateRoute].
///
///
class NavigationSaver extends NavigatorObserver {
  NavigationSaver(
    this._navigationRoutesSaver,
    this._navigationRoutesRestorer, {
    String defaultNavigationRoute,
    bool autoStartStopLogic = true,
  })  : assert(null != _navigationRoutesSaver,
            'navigationRoutesSaver should not ne null'),
        assert(null != _navigationRoutesRestorer,
            'navigationRoutesRestorer should not ne null'),
        assert(null != autoStartStopLogic,
            'autoStartStopLogic should not ne null'),
        this._defaultNavigationRoute =
            defaultNavigationRoute ?? Navigator.defaultRouteName,
        _autoStartStopLogic = autoStartStopLogic;

  static final String restoreRouteName = 'navigationSaverRestore';

  final NavigationRoutesSaver _navigationRoutesSaver;
  final NavigationRoutesRestorer _navigationRoutesRestorer;

  /// route that will be used to start main application
  final String _defaultNavigationRoute;

  /// used to auto subscribe to save/restore logic
  final bool _autoStartStopLogic;

  int _routesVersion = 0;
  final List<Route<dynamic>> _activeRoutes = <Route<dynamic>>[];

  final StreamController<_RoutesListInfo> _routesToSaveStreamController =
      StreamController();
  StreamSubscription _routesToSaveStreamSubscription;

  /// Call this method from the initial widget to move your app to the root widget
  /// or restore previous navigation stack.
  ///
  /// Usually you shouldn't use it directly. Only [NavigationRestorationWidget] usually use it.
  Future<void> restorePreviousRoutes(BuildContext context) async {
    final Iterable<RouteSettings> routeSettings =
        await _navigationRoutesRestorer();
    if (null == routeSettings) {
      throw ArgumentError.notNull('routeSettings');
    }

    _restoreRoutesInternal(context, routeSettings.toList());
  }

  /// This method handles route with name [NavigationSaver.restoreRouteName]
  /// and pushes [NavigationRestorationWidget] to restore navigation stack.
  /// Otherwise this method will convert route settings
  /// and split them if it is an instance of [RestoredArguments] class.
  ///
  /// If you want to have your own content for the restoration time to show on the screen.
  /// Just pass `restoreRouteWidgetBuilder` argument here.
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

  void init() {
    _subscribeToStream();
  }

  void dispose() {
    _disposeStream();
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

    if (_activeRoutes.isEmpty && _autoStartStopLogic) {
      _disposeStream();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (_activeRoutes.isEmpty && _autoStartStopLogic) {
      _subscribeToStream();
    }

    _activeRoutes.add(route);
    _routesVersion++;
    _saveRoutes();
  }

  void _saveRoutes() {
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
    _routesToSaveStreamController.sink
        .add(_RoutesListInfo(_routesVersion, localActiveRouteSettings));
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

  void _subscribeToStream() {
    if (null == _routesToSaveStreamSubscription) {
      _routesToSaveStreamSubscription = _routesToSaveStreamController.stream
          .asyncMap((_RoutesListInfo info) async {
        if (info.version == _routesVersion) {
          await _navigationRoutesSaver(info.routes);
        }
      }).listen(
        (_) {},
        onError: (e, _) {
          debugPrint('error happened during navigationRouteSaver call. $e');
        },
        cancelOnError: false,
      );
    }
  }

  void _disposeStream() {
    if (null != _routesToSaveStreamSubscription) {
      _routesToSaveStreamSubscription.cancel();
      _routesToSaveStreamSubscription = null;
    }
  }
}

/// Arguments that will be used for all restored routes
@immutable
class RestoredArguments {
  const RestoredArguments(
    this.nextPageInfo,
    this.arguments,
  );

  /// Not null if there is any next route after the current.
  /// Contains information about the next route.
  final NextPageInfo nextPageInfo;

  /// Original route arguments
  final Object arguments;
}

/// Class that represents the next route.
@immutable
class NextPageInfo {
  const NextPageInfo(
    this.routeName,
    this.resultFuture,
  );

  /// route name like [RouteSettings.name]
  final String routeName;

  /// route result future like [Route.popped]
  final Future resultFuture;
}

/// This widget will call [NavigationSaver.restoreRouteWidgetBuilder] in its init method
/// and show the `child` during its life.
class NavigationRestorationWidget extends StatefulWidget {
  NavigationRestorationWidget({
    @required this.navigationSaver,
    @required this.child,
  });

  /// Liked navigation saver class
  final NavigationSaver navigationSaver;

  /// Widget to show
  final Widget child;

  @override
  State<StatefulWidget> createState() => _NavigationRestorationState();
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

@immutable
class _RoutesListInfo {
  const _RoutesListInfo(
    this.version,
    this.routes,
  );

  final int version;
  final List<RouteSettings> routes;
}
