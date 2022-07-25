// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offeredAchievements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferedAchievements _$OfferedAchievementsFromJson(Map<String, dynamic> json) =>
    OfferedAchievements(
      achievementID: json['id'] as String?,
      title: json['title'] as String?,
      desc: json['description'] as String?,
      body: json['body'] as String?,
      event: json['event'] as String?,
      priority: json['priority'] as int?,
      secret: json['secret'] as String?,
      stat: json['stat'] as int?,
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      generic: json['generic'] as String?,
    );

Map<String, dynamic> _$OfferedAchievementsToJson(
        OfferedAchievements instance) =>
    <String, dynamic>{
      'id': instance.achievementID,
      'title': instance.title,
      'description': instance.desc,
      'body': instance.body,
      'event': instance.event,
      'priority': instance.priority,
      'secret': instance.secret,
      'generic': instance.generic,
      'users': instance.users,
      'stat': instance.stat,
    };
