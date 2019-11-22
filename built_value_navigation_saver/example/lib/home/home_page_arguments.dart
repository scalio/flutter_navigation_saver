import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'home_page_arguments.g.dart';

abstract class MyHomePageArguments implements Built<MyHomePageArguments, MyHomePageArgumentsBuilder> {

 MyHomePageArguments._();

 factory MyHomePageArguments([
  void Function(MyHomePageArgumentsBuilder) updates,
 ]) = _$MyHomePageArguments;

 static Serializer<MyHomePageArguments> get serializer => _$myHomePageArgumentsSerializer;

 int get deepIndex;
}
