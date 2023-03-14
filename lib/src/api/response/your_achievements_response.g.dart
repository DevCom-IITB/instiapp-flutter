// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'your_achievements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YourAchievementsResponse _$YourAchievementsResponseFromJson(
        Map<String, dynamic> json) =>
    YourAchievementsResponse(
      (json['data'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$YourAchievementsResponseToJson(
        YourAchievementsResponse instance) =>
    <String, dynamic>{
      'data': instance.achievements,
    };
