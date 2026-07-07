import 'package:json_annotation/json_annotation.dart';
import 'package:InstiApp/src/api/model/calendar_body_preference.dart';

part 'calendar_pref_body_response.g.dart';


// response format is
// [
//   { 
//     "body_id":"a13200df-9869-4a35-a5cc-d7e4fc273ab3",
//     "body_name":"jithin",
//     "enabled":true
//    }
// ]

@JsonSerializable()
class CalendarPrefBodyResponse {
  List<CalendarBodyPreference>? items;

  CalendarPrefBodyResponse({
    this.items,
  });

  factory CalendarPrefBodyResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarPrefBodyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarPrefBodyResponseToJson(this);
}