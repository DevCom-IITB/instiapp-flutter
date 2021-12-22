// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      adminNote: json['admin_note'] as String?,
      description: json['description'] as String?,
      body: json['body_detail'] == null
          ? null
          : Body.fromJson(json['body_detail'] as Map<String, dynamic>),
      offer: json['offer'] as String?,
      dismissed: json['dismissed'] as bool?,
      verified: json['verified'] as bool?,
      event: json['event_detail'] == null
          ? null
          : Event.fromJson(json['event_detail'] as Map<String, dynamic>),
      hidden: json['hidden'] as bool?,
      id: json['id'] as String?,
      timeOfCreation: json['time_of_creation'] as String?,
      timeOfModification: json['time_of_modification'] as String?,
      title: json['title'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      verifiedBy: json['verified_by'] == null
          ? null
          : User.fromJson(json['verified_by'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
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
      'body_detail': instance.body,
      'event_detail': instance.event,
      'offer': instance.offer,
    };
