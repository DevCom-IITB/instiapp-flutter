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
      if (instance.id != null) 'id': instance.id,
      if (instance.timeOfCreation != null) 'time_of_creation': instance.timeOfCreation,
      if (instance.timeOfModification != null) 'time_of_modification': instance.timeOfModification,
      if (instance.user != null) 'user': instance.user,
      if (instance.hidden != null) 'hidden': instance.hidden,
      if (instance.dismissed != null) 'dismissed': instance.dismissed,
      if (instance.verified != null) 'verified': instance.verified,
      if (instance.verifiedBy != null) 'verified_by': instance.verifiedBy,
      if (instance.title != null) 'title': instance.title,
      if (instance.description != null) 'description': instance.description,
      if (instance.adminNote != null) 'admin_note': instance.adminNote,
      if (instance.bodyID != null) 'body': instance.bodyID,
      if (instance.body != null) 'body_detail': instance.body,
      if (instance.event != null) 'event_detail': instance.event,
      if (instance.offer != null) 'offer': instance.offer,
      if (instance.isSkill != null) 'isSkill': instance.isSkill,
    };