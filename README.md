![Flutter at Scalio](https://raw.githubusercontent.com/scalio/flutter/master/assets/scalio-fns.svg?sanitize=true)

<h1 align="center">Flutter Navigation Saver</h1>

<p align="center">
  A simple library to restore the navigation stack after an application is killed - for <b><a href="https://flutter.dev/">Flutter</a></b>
</p>

&nbsp;

## Flutter State Issue

Mobile devices inherently have a limited amount of memory. When your application is backgrounded, the OS may need to clear resources for a new program or process, resulting in you app being killed. The next time your application is opened, Flutter simply starts the app with the navigation stack data and all widget state being cleared. See [issue](https://github.com/flutter/flutter/issues/6827)

## Use Case

This library allows you to save all navigation events and their state. On application start, it will restore the previously stored navigation state. To allow for maxiumum customization, it is split into 
smaller modules.

### Restrictions

Flutter uses [Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) for navigation. You can read more [here](https://flutter.dev/docs/development/ui/navigation). This library uses [named routes](https://flutter.dev/docs/cookbook/navigation/named-routes) for saving state, so you are required to use named routes for this library to work properly; 

## Integration Options

There are two default ways to save your routes:
1. [Built Value Module](https://pub.dev/packages/built_value): see instuctions [here](built_value_navigation_saver)
2. [Json Module](https://pub.dev/packages/json_serializable): see instuctions [here](json_navigation_saver)

There are also two other options that require a bit more setup (you will need to handle serialization):

1. [Shared Preferences Module](shared_pref_navigation_saver) 
2. [Core Module](navigation_saver)

## Core module

### How it works:

1. Saves application navigation stack to the class field by implementing [NavigatorObserver](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)
2. Fires save routes callback when user stays on this route for some time.
3. Has `restorePreviousRoutes` method that will clear all current navigation stack and replace it with the restored state. This method should be called only in the application launch.
4. Has `onGenerateRoute` method that will check passed route settings and decide the way how it should be handled. Currently we have only two ways:
	a. If the name of the route is `NavigationSaver.restoreRouteName` - library will push custom widget that will call `restorePreviousRoutes`. You may want to customize how does it look like by passing `restoreRouteWidgetBuilder` parameter.
	b. In all other cases library will check it the route arguments are from the restoration pushing or not.
		a. If this route was pushed by the client code (not the restoration), then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = settings.arguments. Also nextPageInfo will be null.
		b. If this route was pushed by the restoration logic, then it will call `NavigationSaverRouteFactory` with passed settings, routeName = settings.name and routeArguments = restoredRouteArguments (note that after the restoration settings.arguments will have `RestoredArguments` type (See [RestoredArguments](#restoredarguments)). Also nextPageInfo will NOT be null if there is any next route above this one. This may be usefull if you need a result of the next route. See [how should I get a result of the next route after the kill].

### RestoredArguments

Flutter has a great navigation feature - you can wait for the next page result by using `await` keyword. When we restore the navigation stack, we want to keep this ability we restore all routes with the new argument (`RestoredArguments`) class. This class has two fields: real page arguments and the next page information (`NextPageInfo`). See what can you do with it [below](#how-should-i-get-a-result-of-the-next-route-after-the-kill-nextpageinfo-class).

### how should I get a result of the next route after the kill (`NextPageInfo` class)

Imagine you had a stack of widgets A -> B. And widget A was waiting for result of B:


```
  final result = await Navigator.of(context).pushNamed(
    "/next",
    arguments: SomeArgs(),
  );
  // do some work with the result
```

After the restoration logic, the widget stack will be the same: A -> B. However, widget A has never directly started widget B - we did this in our library. If you still need to get the result from B, you can to use the `NextPageInfo` class:

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

2. Check it in the `initState` method and listen for any nextPageInfo:

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

3. You also may want to rewrite initial B widget initialization code:

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
