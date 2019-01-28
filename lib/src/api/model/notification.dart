import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'notification.jser.dart';

final String TYPE_EVENT = "event";
final String TYPE_NEWSENTRY = "newsentry";
final String TYPE_BLOG = "blogentry";

class Notification {
  @Alias("id")
  int notificationId;

  @Alias("verb")
  String notificationVerb;

  @Alias("unread")
  bool notificationUnread;

  @Alias("actor_type")
  String notificationActorType;

  @Alias("actor")
  Object notificationActor;

  String getTitle() {
    if (isEvent) {
      return getEvent().eventName;
    } else if (isNews) {
      return getNews().title;
    } else if (isBlogPost) {
      return getBlogPost().title;
    }
    return "Notification";
  }

  String getSubtitle() {
    return notificationVerb;
  }

  String getAvatarUrl() {
    if (isEvent) {
      var ev = getEvent();
      return ev.eventImageURL ?? ev.eventBodies[0].bodyImageURL;
    } else if (isNews) {
      return getNews().body.bodyImageURL;
    }
    return null;
  }

  bool get isEvent => notificationActorType.contains(TYPE_EVENT);

  bool get isNews => notificationActorType.contains(TYPE_NEWSENTRY);

  bool get isBlogPost => notificationActorType.contains(TYPE_BLOG);

  Event getEvent() {
    return standardSerializers.oneFrom<Event>(notificationActor);
  }

  NewsArticle getNews() {
    return standardSerializers.oneFrom<NewsArticle>(notificationActor);
  }

  Post getBlogPost() {
    return standardSerializers.oneFrom<Post>(notificationActor);
  }

  String getID() {
    if (isEvent) {
      return getEvent().eventID;
    } else if (isNews) {
      return getNews().postID;
    } else if (isBlogPost) {
      return getBlogPost().postID;
    }
    return "";
  }
}

@GenSerializer()
class NotificationSerializer extends Serializer<Notification>
    with _$NotificationSerializer {}
