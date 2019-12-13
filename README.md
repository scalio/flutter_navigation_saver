![Flutter at Scalio](https://raw.githubusercontent.com/scalio/flutter/master/assets/scalio-fns.svg?sanitize=true)

<h1 align="center">Flutter navigation saver library</h1>

<p align="center">
  A library to restore the navigation stack after application kill -- for <b><a href="https://flutter.dev/">Flutter</a></b>
</p>

&nbsp;

## Why you'd use it

Mobile devices have restricted amount of memory they can use. That means if you open an other application the OS may want to clear resources and kill your application. In such case Flutter does nothing: application will run from the start point and all navigation stack and all widget's states will be cleared. See [issue](https://github.com/flutter/flutter/issues/6827)

## Library restrictions

Flutter uses [Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) for navigation. You can read more [here](https://flutter.dev/docs/development/ui/navigation). This library uses [named routes](https://flutter.dev/docs/cookbook/navigation/named-routes) for saving. So if you push any route without usage of named routes - this library will not help and that routes will never be restored.

## What does this library do

This library listen for all your navigation events and save them. On the application start up it restores previous back stack or launch default route for your application. For the biggest customization abilities this library is splitted into the modules.

## The easiest way to integrate

You need to choose what way will you save your routes. Library has 2 build in ways:
1. For [Built Value](https://pub.dev/packages/built_value) see [built value module](built_value_navigation_saver) instructions.
2. For [Json](https://pub.dev/packages/json_serializable) see [json module](json_navigation_saver) instructions.
3. Otherwise you will have to use [shared prefreferences module](shared_pref_navigation_saver) or [core module](navigation_saver) and write serialization yourself.

## Core module

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

Flutter has a great feature in the navigation - you can wait for the next page result by using `await` keyword. And because when we restore the navigation stack we want to keep this ability we restore all routes with the new argument (`RestoredArguments`) class. This class has 2 fields: real page arguments and the next page information (`NextPageInfo`). See what can you do with it [bellow](#how-should-i-get-a-result-of-the-next-route-after-the-kill-nextpageinfo-class).

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

## About Scalio

<p align="center">
    <br/>
    <a href="https://scal.io/">
        <img src="https://raw.githubusercontent.com/scalio/flutter/master/assets/scalio-logo.svg?sanitize=true" />
    </a>
    <br/>
</p>
