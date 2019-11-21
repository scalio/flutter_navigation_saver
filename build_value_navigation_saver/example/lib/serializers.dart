import 'package:build_value_navigation_saver/navigation_saver_routes_info.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:example/home/home_page_arguments.dart';

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
  MyHomePageArguments,
])
final Serializers serializers = (_$serializers.toBuilder()).build();
