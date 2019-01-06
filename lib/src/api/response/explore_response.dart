import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'explore_response.jser.dart';

class ExploreResponse {
  @Alias("bodies")
  List<Body> bodies;
  @Alias("events")
  List<Event> events;
  @Alias("users")
  List<User> users;

  ExploreResponse({this.bodies, this.events, this.users});
}

@GenSerializer()
class ExploreResponseSerializer extends Serializer<ExploreResponse> with _$ExploreResponseSerializer {}