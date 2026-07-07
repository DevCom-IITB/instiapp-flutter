import 'package:json_annotation/json_annotation.dart';

part 'calendar_body.g.dart';

@JsonSerializable()
class CalendarBody {
  @JsonKey(name: 'body_id')
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

  CalendarBody({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.color,
    this.isPublic,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarBody.fromJson(Map<String, dynamic> json) =>
      _$CalendarBodyFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarBodyToJson(this);
}
