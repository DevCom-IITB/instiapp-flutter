import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'body.jser.dart';

class Body {
  @Alias("id")
  String bodyID;

  @Alias("str_id")
  String bodyStrID;

  @Alias("name")
  String bodyName;

  @Alias("short_description")
  String bodyShortDescription;

  @Alias("description")
  String bodyDescription;

  @Alias("image_url")
  String bodyImageURL;

  @Alias("children")
  List<Body> bodyChildren;

  @Alias("parents")
  List<Body> bodyParents;

  @Alias("events")
  List<Event> bodyEvents;

  @Alias("followers_count")
  int bodyFollowersCount;

  @Alias("website_url")
  String bodyWebsiteURL;

  @Alias("blog_url")
  String bodyBlogURL;

  @Alias("user_follows")
  bool bodyUserFollows;

  @Alias("roles")
  List<Role> bodyRoles;
}

@GenSerializer()
class BodySerializer extends Serializer<Body> with _$BodySerializer {}
