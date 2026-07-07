import 'package:json_annotation/json_annotation.dart';

part 'calendar_body_preference.g.dart';

@JsonSerializable()
class CalendarBodyPreference {
  @JsonKey(name: 'body_id')
  String? bodyId;

  @JsonKey(name: 'body_name')
  String? bodyName;

  @JsonKey(name: 'enabled')
  bool? enabled;

  CalendarBodyPreference({
    this.bodyId,
    this.bodyName,
    this.enabled,
  });

  factory CalendarBodyPreference.fromJson(Map<String, dynamic> json) =>
      _$CalendarBodyPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarBodyPreferenceToJson(this);
}
