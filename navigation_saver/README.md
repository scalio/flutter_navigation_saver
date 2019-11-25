# Flutter navigation saver library (core module)

This library will help to restore navigation stack after application kill.

## Overview

This is the core library and usually shouldn't be used directly. Please check [general readme](../../../) first. It should be used directly only if you would like have a full control of how routes are saved and restored.

## How to use this library:

1. Be sure that you need exactly this core library. Perhaps it is better to use [shared prefreferences module](../../../shared_pref_navigation_saver).
2. Include dependencies:
  `navigation_saver: ^0.1.0`   - current module
3. Include any argument to disk saving library or write it by yourself: [built value module](../../../built_value_navigation_saver) or [json module](../../../json_navigation_saver)
4. Create `NavigationSaver` class before your application widget:
```
void main() {
  final NavigationSaver _navigatorSaver = NavigationSaver(
    (routes) async => /* todo: add save code */,
    () async => /* todo: add restore code */,
  );

  runApp(MyApp(_navigatorSaver));
}

```
5. Setup `NavigationSaver` as navigation observer and make him generate widgets:
```
class MyApp extends StatelessWidget {
  MyApp(this._navigationSaver);

  final NavigationSaver _navigationSaver;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: NavigationSaver.restoreRouteName,
      onGenerateRoute: (RouteSettings routeSettings) => _navigationSaver.onGenerateRoute(
        routeSettings,
        (
          RouteSettings settings,
          String routeName,
          Object routeArguments, {
          NextPageInfo nextPageInfo,
        }) => /* todo: generate your application widgets here. use `routeName` and `routeArguments` */,
      ),
      navigatorObservers: [_navigationSaver],
    );
  }
}
```
6. This is it. Also you may want to add custom restoration widget that will be shown when library restore your navigation stack. This can be done by passing `restoreRouteWidgetBuilder` paramter to `onGenerateRoute` method.


## How does core module work:

1. Saves application navigation stack to the class field by implementing [NavigatorObserver](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)
2. Fires save routes callback when user stays on this route for some time.
3. `defaultNavigationRoute` parameter is used to when there is no routes to restore and this route will be pushed in that case. Default value is `Navigator.defaultRouteName`.
4. `restorePreviousRoutes` method that will clear all current navigation stack and replace it with the restored state. This method should be called only in the application launch.
5. `onGenerateRoute` method that will check passed route settings and decide the way how it should be handled. Currently we have only 2 ways:
	a. If the name of the route is `NavigationSaver.restoreRouteName` - library will push custom widget that will call `restorePreviousRoutes`. You may want to customize how does it look like by passing `restoreRouteWidgetBuilder` parameter.
	b. In all other cases library will check it the route arguments are from the restoration pushing or not.
		a. If this route was pushed by the client code (not the restoration), then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = settings.arguments. Also nextPageInfo will be null.
		b. If this route was pushed by the restoration logic, then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = restoredRouteArguments (note that after the restoration settings.arguments will have `RestoredArguments` type (See [RestoredArguments](#restoredarguments)). Also nextPageInfo will NOT be null if there is any next route above this one. This may be usefull if you need a result of the next route. See [how should I get a result of the next route after the kill].

## RestoredArguments

Flutter has a great feature in the navigation - you can wait for the next page result by using `await` keyword. And because when we restore the navigation stack we want to keep this ability we restore all routes with the new argument (`RestoredArguments`) class. This class has 2 fields: real page arguments and the next page information (`NextPageInfo`). See what can you do with it [bellow](#how-should-i-get-a-result-of-the-next-route-after-the-kill-nextpageinfo-class).

## How should I get a result of the next route after the kill (`NextPageInfo` class)

Imagine you had a stack of widgets A -> B. And widget A was waiting for result of B. Usually you do this by using such code:


```
  final result = await Navigator.of(context).pushNamed(
    "/next",
    arguments: SomeArgs(),
  );
  // do some work with the result
```

After the restoration logic the widget stack will be the same: A -> B. But there will be a big difference: widget A has never started the widget B - we did this in our library. But if you still want to get the result from B, you will need to use `NextPageInfo` class.

One of the best usage if this class:

1. Save `nextPageInfo` field in your widget class:
```
class AWidget extends StatefulWidget {
  AWidget({
    Key key,
    this.nextPageInfo,
  }) : super(key: key);

  final NextPageInfo nextPageInfo;

  @override
  _AWidgetState createState() => _AWidgetState();
}
```

2. Check it in the `initState` method and if there is some nextPageInfo - listen for it:

```
  @override
  void initState() {
    super.initState();

    if (null != widget.nextPageInfo) {
      switch (widget.nextPageInfo.routeName) {
        case '/next':
          awaitNextPageResult(widget.nextPageInfo.resultFuture);
          break;
      }
    }
  }

  Future<void> awaitNextPageResult(Future resultFuture) async {
    final result = await resultFuture;
    // do some work with the result
  }
```

3. Also you may want to rewrite initial B widget initialization code:

```
  awaitNextPageResult(
    Navigator.of(context).pushNamed(
      "/next",
      arguments: SomeArgs(),
    ),
  );
```
