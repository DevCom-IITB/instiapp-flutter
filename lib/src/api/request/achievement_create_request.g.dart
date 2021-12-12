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
    );

Map<String, dynamic> _$AchievementCreateRequestToJson(
        AchievementCreateRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time_of_creation': instance.timeOfCreation,
      'time_of_modification': instance.timeOfModification,
      'user': instance.user,
      'hidden': instance.hidden,
      'dismissed': instance.dismissed,
      'verified': instance.verified,
      'verified_by': instance.verifiedBy,
      'title': instance.title,
      'description': instance.description,
      'admin_note': instance.adminNote,
      'body': instance.bodyID,
      'body_detail': instance.body,
      'event_detail': instance.event,
      'offer': instance.offer,
    };
