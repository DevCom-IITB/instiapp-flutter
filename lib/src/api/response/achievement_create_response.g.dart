// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AchievementCreateResponse _$AchievementCreateResponseFromJson(
        Map<String, dynamic> json) =>
    AchievementCreateResponse(
      result: json['result'] as String?,
      achID: json['achID'] as String?,
    );

Map<String, dynamic> _$AchievementCreateResponseToJson(
        AchievementCreateResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'achID': instance.achID,
    };
