# Flutter navigation saver library (json module)

This library will help to restore navigation stack after application kill.

## Overview

This library should be used if you want to convert argument classes to string by using [json serialization](https://pub.dev/packages/json_serializable) library. Our library has helper classes that will remove most of boilerplate code.
This library works best with `shared prefreferences module` [github link](../shared_pref_navigation_saver) or [pub link](https://pub.dev/packages/shared_pref_navigation_saver).


## How to use this library:

1. Include dependencies:
	
	a. `build_value_navigation_saver: ^0.3.2` 	- current module that includes helper classes for build value integration.

	b. `shared_pref_navigation_saver: ^0.3.2` 	- module that will do actual navigation saving and restoring logic with core navigation saver library ([github link](../navigation_saver) or [pub link](https://pub.dev/packages/navigation_saver)).
	
	c. `json_annotation: ^3.0.0`				- built value integration. for more information see this [link](https://pub.dev/packages/json_serializable)
2. Include dev dependencies:
	
	a. `build_runner: ^1.0.0`					- built value integration. for more information see this [link](https://pub.dev/packages/json_serializable)
	
	b. `json_serializable: ^3.2.0`			    - built value integration. for more information see this [link](https://pub.dev/packages/json_serializable)
3. Run `flutter pub upgrade` and `flutter pub get`
4. Initialize `NavigationSaver` class before your application widget:
```
import 'dart:convert';
import 'package:json_navigation_saver/json_navigation_saver.dart';
import 'package:shared_pref_navigation_saver/shared_pref_navigation_saver.dart';
import 'package:navigation_saver/navigation_saver.dart';
import 'serializers.dart';

void main() {
  final NavigationSaver navigatorSaver = SharedPrefNavigationSaver(
    (Iterable<RouteSettings> routes) async => json.encode(serializeRoutes(serializers, routes)),
    (String routesAsString) async => deserializeRoutes(serializers, json.decode(routesAsString)),
  );

  runApp(MyApp(navigatorSaver));
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
          RouteSettings settings, {
          NextPageInfo nextPageInfo,
        }) => /* todo: generate your application widgets here. use `settings`, not `routeSettings` object */,
      ),
      navigatorObservers: [_navigationSaver],
    );
  }
}
```
6. You may want to add custom restoration widget that will be shown when library restore your navigation stack. This can be done by passing `restoreRouteWidgetBuilder` parameter in `onGenerateRoute` method.
9. After that you should setup all your arguments with json serialization. See bellow code for instructions.
5. Call `flutter packages pub run build_runner build`.
10. To see how to get result from restored routes see note in the core library: [github](https://github.com/scalio/flutter_navigation_saver#restoredarguments) or [pub](https://pub.dev/packages/navigation_saver#restoredarguments)

## How to use build value library

1. Add `JsonSerializable` annotation for you argument class.
2. Add this code bellow imports and above class definition: 
```
import 'package:json_annotation/json_annotation.dart';
        
part 'argument_class_name_file_name.g.dart';
```
3. Add additional code inside your class:
```
  factory ArgumentClassName.fromJson(Map<String, dynamic> json) =>
      _$ArgumentClassNameFromJson(json);

  Map<String, dynamic> toJson() => _$ArgumentClassNameToJson(this);
```  
4. Do not forget to call `flutter packages pub run build_runner build` after each argument update.


See [json serializable library](https://pub.dev/packages/json_serializable) for additional instructions.


For the complete example see an [example application](example)