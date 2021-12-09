import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'explore_response.g.dart';

class ExploreResponse {
  @JsonKey("bodies")
  List<Body> bodies;
  @JsonKey("events")
  List<Event> events;
  @JsonKey("users")
  List<User> users;

  ExploreResponse({this.bodies, this.events, this.users});
  factory ExploreResponse.fromJson(Map<String, dynamic> json) =>
      _$ExploreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExploreResponseToJson(this);
}

@GenSerializer()
class ExploreResponseSerializer extends Serializer<ExploreResponse>
    with _$ExploreResponseSerializer {}
