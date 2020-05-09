# Flutter navigation saver library (built value module)

This library will help to restore navigation stack after application kill.

## Overview

This library should be used if you want to convert argument classes to string by using [built value](https://pub.dev/packages/built_value) library. Our library has helper classes that will remove most of boilerplate code.
This library works best with `shared prefreferences module` [github link](../shared_pref_navigation_saver) or [pub link](https://pub.dev/packages/shared_pref_navigation_saver).


## How to use this library:

1. Include dependencies:
        
	a. `build_value_navigation_saver: ^0.3.2` 	- current module that includes helper classes for build value integration.
        
	b. `shared_pref_navigation_saver: ^0.3.2` 	- module that will do actual navigation saving and restoring logic with core navigation saver library ([github link](../navigation_saver) or [pub link](https://pub.dev/packages/navigation_saver)).
        
	c. `built_value: ^7.0.0`					- built value integration. for more information see this [link](https://pub.dev/packages/built_value)
2. Include dev dependencies:
	
	a. `build_runner: ^1.0.0`					- built value integration. for more information see this [link](https://pub.dev/packages/built_value)
	
	b. `built_value_generator: ^7.0.0`			- built value integration. for more information see this [link](https://pub.dev/packages/built_value)
3. Run `flutter pub upgrade` and `flutter pub get`
4. Create `serializers.dart` file near the `main.dart` file with the following code:
```
import 'package:build_value_navigation_saver/navigation_saver_routes_info.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'serializers.g.dart';

/// Example of how to use built_value serialization.
///
/// Declare a top level [Serializers] field called serializers. Annotate it
/// with [SerializersFor] and provide a `const` `List` of types you want to
/// be serializable.
///
/// The built_value code generator will provide the implementation. It will
/// contain serializers for all the types asked for explicitly plus all the
/// types needed transitively via fields.
///
/// You usually only need to do this once per project.
@SerializersFor([
  RoutesInfo,
  NavigatorRouteSettings,
  /* todo: add all other Arguments that you pass to your routes */
])
final Serializers serializers = (_$serializers.toBuilder()).build();
```
5. Call `flutter packages pub run build_runner build`. If you do everything correctly it will build `serializers.g.dart` file and all missed imports will gone. If something goes wrong see the [build value documentation](https://pub.dev/packages/built_value)
6. Initialize `NavigationSaver` class before your application widget:
```
import 'dart:convert';
import 'package:build_value_navigation_saver/navigation_saver_routes_info.dart';
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
7. Setup `NavigationSaver` as navigation observer and make him generate widgets:
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
8. You may want to add custom restoration widget that will be shown when library restore your navigation stack. This can be done by passing `restoreRouteWidgetBuilder` parameter in `onGenerateRoute` method.
9. After that you should extend all your arguments from `Built` class and specify them in `serializers.dart` file. See bellow code for instructions.
10. To see how to get result from restored routes see note in the core library: [github](https://github.com/scalio/flutter_navigation_saver#restoredarguments) or [pub](https://pub.dev/packages/navigation_saver#restoredarguments)

## How to use build value library

1. Specify your argument class as abstract.
2. Add `implements Built<ArgumentClassName, ArgumentClassNameBuilder>`.
3. Add this code bellow imports and above class definition: 
```
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
        
part 'argument_class_name_file_name.g.dart';
```
4. Add additional code inside your class:
```
  factory ArgumentClassName([
    void Function(ArgumentClassNameBuilder) updates,
  ]) = _$ArgumentClassName;

  ArgumentClassName._();

  static Serializer<ArgumentClassName> get serializer =>
      _$argumentClassNameSerializer;
```  
5. Change all final fields to getters. For example if you have `int field` change the code like this:
from: `final int field;`
to: `int get field;`
6. It is better to have arguments class in a separate file because otherwise you will have to deal with naming conflicts (for example class in `Builder` is defined in `package:built_value/built_value.dart` and `package:flutter/widgets.dart`)
7. Do not forget to call `flutter packages pub run build_runner build` after each argument update.


See [build value library](https://pub.dev/packages/built_value) for additional instructions.


For the complete example see an [example application](example)
