// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resobin_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResobinCourse _$ResobinCourseFromJson(Map<String, dynamic> json) =>
    ResobinCourse(
      id: (json['id'] as num).toInt(),
      createdBy: json['created_by'] as String?,
      course: json['course'] == null
          ? null
          : ResobinCourseDetail.fromJson(
              json['course'] as Map<String, dynamic>),
      division: json['division'] as String?,
      lectureSlots: (json['lecture_slots'] as List<dynamic>?)
          ?.map((e) => ResobinSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      tutorialSlots: (json['tutorial_slots'] as List<dynamic>?)
          ?.map((e) => ResobinSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      lectureVenue: json['lecture_venue'] as String?,
      professor: json['professor'] as String?,
    );

Map<String, dynamic> _$ResobinCourseToJson(ResobinCourse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_by': instance.createdBy,
      'course': instance.course,
      'division': instance.division,
      'lecture_slots': instance.lectureSlots,
      'tutorial_slots': instance.tutorialSlots,
      'lecture_venue': instance.lectureVenue,
      'professor': instance.professor,
    };

ResobinCourseDetail _$ResobinCourseDetailFromJson(Map<String, dynamic> json) =>
    ResobinCourseDetail(
      code: json['code'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ResobinCourseDetailToJson(
        ResobinCourseDetail instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
    };

ResobinSlot _$ResobinSlotFromJson(Map<String, dynamic> json) => ResobinSlot(
      slot: json['slot'] as String?,
      day: json['day'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );

Map<String, dynamic> _$ResobinSlotToJson(ResobinSlot instance) =>
    <String, dynamic>{
      'slot': instance.slot,
      'day': instance.day,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };
