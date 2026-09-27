// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AchievementCreateRequest _$AchievementCreateRequestFromJson(
        Map<String, dynamic> json) =>
    AchievementCreateRequest(
      id: json['id'] as String?,
      timeOfCreation: json['time_of_creation'] as String?,
      timeOfModification: json['time_of_modification'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      hidden: json['hidden'] as bool?,
      dismissed: json['dismissed'] as bool?,
      verified: json['verified'] as bool?,
      verifiedBy: json['verified_by'] == null
          ? null
          : User.fromJson(json['verified_by'] as Map<String, dynamic>),
      title: json['title'] as String?,
      description: json['description'] as String?,
      adminNote: json['admin_note'] as String?,
      bodyID: json['body'] as String?,
      body: json['body_detail'] == null
          ? null
          : Body.fromJson(json['body_detail'] as Map<String, dynamic>),
      event: json['event_detail'] == null
          ? null
          : Event.fromJson(json['event_detail'] as Map<String, dynamic>),
      offer: json['offer'] as String?,
      isSkill: json['isSkill'] as bool?,
    );

Map<String, dynamic> _$AchievementCreateRequestToJson(
        AchievementCreateRequest instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.timeOfCreation case final value?) 'time_of_creation': value,
      if (instance.timeOfModification case final value?)
        'time_of_modification': value,
      if (instance.user case final value?) 'user': value,
      if (instance.hidden case final value?) 'hidden': value,
      if (instance.dismissed case final value?) 'dismissed': value,
      if (instance.verified case final value?) 'verified': value,
      if (instance.verifiedBy case final value?) 'verified_by': value,
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      if (instance.adminNote case final value?) 'admin_note': value,
      if (instance.bodyID case final value?) 'body': value,
      if (instance.body case final value?) 'body_detail': value,
      if (instance.event case final value?) 'event_detail': value,
      if (instance.offer case final value?) 'offer': value,
      if (instance.isSkill case final value?) 'isSkill': value,
    };
