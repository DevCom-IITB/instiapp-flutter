import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'body.g.dart';

class Body {
  @JsonKey("id")
  String bodyID;

  @JsonKey("str_id")
  String bodyStrID;

  @JsonKey("name")
  String bodyName;

  @JsonKey("short_description")
  String bodyShortDescription;

  @JsonKey("description")
  String bodyDescription;

  @JsonKey("image_url")
  String bodyImageURL;

  @JsonKey("children")
  List<Body> bodyChildren;

  @JsonKey("parents")
  List<Body> bodyParents;

  @JsonKey("events")
  List<Event> bodyEvents;

  @JsonKey("followers_count")
  int bodyFollowersCount;

  @JsonKey("website_url")
  String bodyWebsiteURL;

  @JsonKey("blog_url")
  String bodyBlogURL;

  @JsonKey("user_follows")
  bool bodyUserFollows;

  @JsonKey("roles")
  List<Role> bodyRoles;
}

@GenSerializer()
class BodySerializer extends Serializer<Body> with _$BodySerializer {}
