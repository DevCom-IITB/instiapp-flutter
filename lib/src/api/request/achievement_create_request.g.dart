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
    AchievementCreateRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('time_of_creation', instance.timeOfCreation);
  writeNotNull('time_of_modification', instance.timeOfModification);
  writeNotNull('user', instance.user);
  writeNotNull('hidden', instance.hidden);
  writeNotNull('dismissed', instance.dismissed);
  writeNotNull('verified', instance.verified);
  writeNotNull('verified_by', instance.verifiedBy);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('admin_note', instance.adminNote);
  writeNotNull('body', instance.bodyID);
  writeNotNull('body_detail', instance.body);
  writeNotNull('event_detail', instance.event);
  writeNotNull('offer', instance.offer);
  writeNotNull('isSkill', instance.isSkill);
  return val;
}
