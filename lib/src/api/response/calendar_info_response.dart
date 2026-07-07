import 'package:InstiApp/src/api/model/calendar_body_preference.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:InstiApp/src/api/model/calendar_body.dart';

part 'calendar_info_response.g.dart';


// response format is
//  {
//   "id":"d67f9ff0-d34a-45ec-9edd-e073c3765678",
//    "name":"IIT Bombay Academic Calendar 2025-26",
//    "slug":"iitb-academic-2025-26",
//    "description":"Official academic calendar",
//    "color":"#E53935",
//    "is_public":true,
//    "is_active":true,
//    "created_at":"2026-05-21T23:40:56.986943+05:30",
//    "updated_at":"2026-05-21T23:40:56.986943+05:30",
//    "upcoming_events":[]
// }



@JsonSerializable()
class CalendarInfoResponse {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'slug')
  String? slug;

  @JsonKey(name: 'description')
  String? description;

  @JsonKey(name: 'color')
  String? color;

  @JsonKey(name: 'is_public')
  bool? isPublic;

  @JsonKey(name: 'is_active')
  bool? isActive;

  @JsonKey(name: 'created_at')
  String? createdAt;

  @JsonKey(name: 'updated_at')
  String? updatedAt;

  @JsonKey(name: 'upcoming_events')
  List<CalendarBody>? items;

  CalendarInfoResponse({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.color,
    this.isPublic,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory CalendarInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarInfoResponseToJson(this);
}