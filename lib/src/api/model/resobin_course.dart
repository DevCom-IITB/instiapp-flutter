import 'package:json_annotation/json_annotation.dart';

part 'resobin_course.g.dart';

@JsonSerializable()
class ResobinCourse {
  final int id;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  final ResobinCourseDetail? course;
  final String? division;
  @JsonKey(name: 'lecture_slots')
  final List<ResobinSlot>? lectureSlots;
  @JsonKey(name: 'tutorial_slots')
  final List<ResobinSlot>? tutorialSlots;
  @JsonKey(name: 'lecture_venue')
  final String? lectureVenue;
  final String? professor;

  ResobinCourse({
    required this.id,
    this.createdBy,
    this.course,
    this.division,
    this.lectureSlots,
    this.tutorialSlots,
    this.lectureVenue,
    this.professor,
  });

  factory ResobinCourse.fromJson(Map<String, dynamic> json) =>
      _$ResobinCourseFromJson(json);
  Map<String, dynamic> toJson() => _$ResobinCourseToJson(this);
}

@JsonSerializable()
class ResobinCourseDetail {
  final String? code;
  final String? title;

  ResobinCourseDetail({this.code, this.title});

  factory ResobinCourseDetail.fromJson(Map<String, dynamic> json) =>
      _$ResobinCourseDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ResobinCourseDetailToJson(this);
}

@JsonSerializable()
class ResobinSlot {
  final String? slot;
  final String? day;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;

  ResobinSlot({this.slot, this.day, this.startTime, this.endTime});

  factory ResobinSlot.fromJson(Map<String, dynamic> json) =>
      _$ResobinSlotFromJson(json);
  Map<String, dynamic> toJson() => _$ResobinSlotToJson(this);
}
