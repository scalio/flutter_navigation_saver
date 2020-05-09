# Flutter navigation saver library (shared preferences module)

This library will help to restore navigation stack after application kill.

## Overview

This library should be used if you have some special way of serializing arguments into the string and back. Also do not forget to check [general readme](../../../).


## How does this module work:

1. It uses the core module ([git link](../navigation_saver) or [pub link](https://pub.dev/packages/navigation_saver)) and extends it to save routes to the [shared preferences](https://pub.dev/packages/shared_preferences).
2. All the control of converting routes to string is up to the application user code.
3. `maximumDurationBetweenRestoration` is used to understand if we need to restore routes or too much time was passed. Default is 5 minutes.

## General implementation:

1. Include dependencies:
  `shared_pref_navigation_saver: ^0.3.2`   - current module
2. Include any argument to disk saving library or write it by yourself. We suggest `build value` ([git hub](../built_value_navigation_saver) or [pub link](https://pub.dev/packages/build_value_navigation_saver)) or `json module` ([git hub](../json_navigation_saver) or [pub link](https://pub.dev/packages/json_navigation_saver)).
3. Create `NavigationSaver` class before your application widget:
```
import 'package:build_value_navigation_saver/navigation_saver_routes_info.dart';
import 'package:shared_pref_navigation_saver/shared_pref_navigation_saver.dart';

void main() {
  final NavigationSaver _navigatorSaver = SharedPrefNavigationSaver(
    (Iterable<RouteSettings> routes) async => /* todo: add save code */,
    (String routesAsString) async => /* todo: add restore code */,
  );

  runApp(MyApp(_navigatorSaver));
}

```
4. Setup `NavigationSaver` as navigation observer and route generator:
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
5. This is it. Also you may want to add custom restoration widget that will be shown when library restore your navigation stack. This can be done by passing `restoreRouteWidgetBuilder` parameter in `onGenerateRoute` method.
6. You may want to add custom restoration widget that will be shown when library restore your navigation stack. This can be done by passing `restoreRouteWidgetBuilder` parameter in `onGenerateRoute` method.
7. To see how to get result from restored routes see note in the core library: [github](https://github.com/scalio/flutter_navigation_saver#restoredarguments) or [pub](https://pub.dev/packages/navigation_saver#restoredarguments)


Please check `built value module` ([githib link](../built_value_navigation_saver) or [pub link](https://pub.dev/packages/build_value_navigation_saver)) or `json module` ([github link](../json_navigation_saver) or [pub link](https://pub.dev/packages/json_navigation_saver)) for argument to map converting logic.