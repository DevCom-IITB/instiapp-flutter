import 'package:InstiApp/src/api/model/calendar_body_preference.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:InstiApp/src/api/model/calendar_body.dart';

part 'calendar_share_response.g.dart';


// response format is
// [
//     {
//         "id": "b9121d66-4b35-4ab1-a9f8-d6b7c42ddf6c",
//         "name": "jithin",
//         "slug": "iitb-ac",
//         "description": "hello",
//         "color": "yellow",
//         "is_public": true,
//         "is_active": true,
//         "created_at": "2026-05-21T17:30:03.381398+05:30",
//         "updated_at": "2026-05-21T17:30:03.381398+05:30"
//     },
//     {
//         "id": "d67f9ff0-d34a-45ec-9edd-e073c3765678",
//         "name": "IIT Bombay Academic Calendar 2025-26",
//         "slug": "iitb-academic-2025-26",
//         "description": "Official academic calendar",
//         "color": "#E53935",
//         "is_public": true,
//         "is_active": true,
//         "created_at": "2026-05-21T23:40:56.986943+05:30",
//         "updated_at": "2026-05-21T23:40:56.986943+05:30"
//     },
//     {
//         "id": "d2b3af34-b35e-45e5-9d1d-9c915f6956bc",
//         "name": "ens sem",
//         "slug": "iiib-academic",
//         "description": "fsffsddfs",
//         "color": "yellow",
//         "is_public": true,
//         "is_active": true,
//         "created_at": "2026-05-25T21:13:46.569899+05:30",
//         "updated_at": "2026-05-25T21:13:46.569899+05:30"
//     }
// ]



@JsonSerializable()
class   CalendarShareResponse {
  List<CalendarBody>? items;

  CalendarShareResponse({
    this.items,
  });

  factory CalendarShareResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarShareResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarShareResponseToJson(this);
}