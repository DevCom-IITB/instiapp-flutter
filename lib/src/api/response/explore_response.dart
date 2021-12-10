import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'explore_response.g.dart';

@JsonSerializable()
class ExploreResponse {
  @JsonKey(name: "bodies")
  List<Body>? bodies;
  @JsonKey(name: "events")
  List<Event>? events;
  @JsonKey(name: "users")
  List<User>? users;

  ExploreResponse({this.bodies, this.events, this.users});
  factory ExploreResponse.fromJson(Map<String, dynamic> json) =>
      _$ExploreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExploreResponseToJson(this);
}
