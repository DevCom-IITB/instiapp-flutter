// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExploreResponse _$ExploreResponseFromJson(Map<String, dynamic> json) =>
    ExploreResponse(
      bodies: (json['bodies'] as List<dynamic>?)
          ?.map((e) => Body.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExploreResponseToJson(ExploreResponse instance) =>
    <String, dynamic>{
      'bodies': instance.bodies,
      'events': instance.events,
      'users': instance.users,
    };
