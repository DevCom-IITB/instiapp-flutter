import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'explore_response.g.dart';

@JsonSerializable()
class ExploreResponse {
<<<<<<< HEAD
  @Alias("bodies")
  List<Body> bodies;
  @Alias("events")
  List<Event> events;
  @Alias("users")
  List<User> users;
  @Alias("interests")
  List<Interest> interest;
  @Alias("skills")
  List<Skill> skills;
=======
  @JsonKey(name: "bodies")
  List<Body>? bodies;
  @JsonKey(name: "events")
  List<Event>? events;
  @JsonKey(name: "users")
  List<User>? users;
>>>>>>> 979eea57d0f6b8b4c1a6fc4046d90e8fa671fe78

  ExploreResponse({this.bodies, this.events, this.users});
  factory ExploreResponse.fromJson(Map<String, dynamic> json) =>
      _$ExploreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExploreResponseToJson(this);
}
