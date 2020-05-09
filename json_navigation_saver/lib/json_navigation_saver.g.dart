// GENERATED CODE - DO NOT MODIFY BY HAND

part of json_navigation_saver;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutesInfo _$RoutesInfoFromJson(Map<String, dynamic> json) {
  return RoutesInfo(
    routes: (json['routes'] as List)
        .map((e) => NavigatorRouteSettings.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$RoutesInfoToJson(RoutesInfo instance) =>
    <String, dynamic>{
      'routes': instance.routes.map((e) => e.toJson()).toList(),
    };

NavigatorRouteSettings _$NavigatorRouteSettingsFromJson(
    Map<String, dynamic> json) {
  return NavigatorRouteSettings(
    name: json['name'] as String,
    arguments: json['arguments'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$NavigatorRouteSettingsToJson(
        NavigatorRouteSettings instance) =>
    <String, dynamic>{
      'name': instance.name,
      'arguments': instance.arguments,
    };
