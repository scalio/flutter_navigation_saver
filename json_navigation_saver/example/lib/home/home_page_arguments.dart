import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home_page_arguments.g.dart';

@JsonSerializable(
  nullable: false,
  explicitToJson: true,
)
class MyHomePageArguments {
  const MyHomePageArguments({
    @required this.deepIndex,
  });

  factory MyHomePageArguments.fromJson(Map<String, dynamic> json) =>
      _$MyHomePageArgumentsFromJson(json);

  final int deepIndex;

  Map<String, dynamic> toJson() => _$MyHomePageArgumentsToJson(this);
}
