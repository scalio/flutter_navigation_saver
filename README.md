# Flutter navigation saver library

This library will help to restore navigation stack after application kill.

## Why would you like to use it

Mobile devices have restricted amount of memory they can use. That means if you open an other application the OS may want to clear resources and kill your application. In such case Flutter does nothing: application will run from the start point and all navigation stack and all widget's states will be cleared. See [issue](https://github.com/flutter/flutter/issues/6827)

## What does this package do

This package listen for all your navigation events and save them. On the application start up it restores previous back stack or launch default route for your application. For the biggest customization abilities this library is splitted into the modules.

1. The main navigation related logic is located in the [core module](navigation_saver)
2. The saving/restore logic to the shared preferences is located in the [shared prefreferences module](shared_pref_navigation_saver)
3. Because Flutter does not have refrection you will need to save routes and there arguments by yourself, but we have some modules that will save your time in bollerplate:
	a. [Built Value](https://pub.dev/packages/built_value) way of saving is located in the [built value module](built_value_navigation_saver)
	b. [Json Serializable](https://pub.dev/packages/json_serializable) way of saving is located in the [json module](json_navigation_saver)


## [Core module](navigation_saver)

### How does it work:

1. Saves application navigation stack to the class field by implementing [NavigatorObserver](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)
2. Fires save routes callback when user stays on this route for some time.
3. Has `restorePreviousRoutes` method that will clear all current navigation stack and replace it with the restored state. This method should be called only in the application launch.
4. Has `onGenerateRoute` method that will check passed route settings and decide the way how it should be handled. Currently we have only 2 ways:
	a. If the name of the route is `NavigationSaver.restoreRouteName` - library will push custom widget that will call `restorePreviousRoutes`. You may want to customize how does it look like by passing `restoreRouteWidgetBuilder` parameter.
	b. In all other cases library will check it the route arguments are from the restoration pushing or not.
		a. If this route was pushed by the client code (not the restoration), then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = settings.arguments. Also nextPageInfo will be null.
		b. If this route was pushed by the restoration logic, then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = restoredRouteArguments (note that after the restoration settings.arguments will have `RestoredArguments` type (See [RestoredArguments](#restoredarguments)). Also nextPageInfo will NOT be null if there is any next route above this one. This may be usefull if you need a result of the next route. See [how should I get a result of the next route after the kill].

### RestoredArguments

Flutter has a great feature in the navigation - you can wait for the next page result by using `await` keyword. And because when we restore the navigation stack we want to keep this ability we restore all routes with the new argument (`RestoredArguments`) class. This class has 2 fields: real page arguments and the next page information (`NextPageInfo`). See what can you do with it bellow.

### how should I get a result of the next route after the kill (`NextPageInfo` class)

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
    await Navigator.of(context).pushNamed(
      "/next",
      arguments: SomeArgs(),
    ),
  );
```
