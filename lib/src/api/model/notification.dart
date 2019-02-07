import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'notification.jser.dart';

const String TYPE_EVENT = "event";
const String TYPE_NEWSENTRY = "newsentry";
const String TYPE_BLOG = "blogentry";
const String TYPE_COMPLAINT_COMMENT = "complaintcomment";

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
    } else if (isComplaintComment) {
      var comment = getComment();
      return "\"${comment.text}\" by ${comment.commentedBy.userName}";
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
    } else if (isComplaintComment) {
      return getComment().commentedBy.userProfilePictureUrl;
    }
    return null;
  }

  bool get isEvent => notificationActorType.contains(TYPE_EVENT);

  bool get isNews => notificationActorType.contains(TYPE_NEWSENTRY);

  bool get isBlogPost => notificationActorType.contains(TYPE_BLOG);

  bool get isComplaintComment =>
      notificationActorType.contains(TYPE_COMPLAINT_COMMENT);

  Event getEvent() {
    return standardSerializers.oneFrom<Event>(notificationActor);
  }

  NewsArticle getNews() {
    return standardSerializers.oneFrom<NewsArticle>(notificationActor);
  }

  Post getBlogPost() {
    return standardSerializers.oneFrom<Post>(notificationActor);
  }

  Comment getComment() {
    return standardSerializers.oneFrom<Comment>(notificationActor);
  }

  String getID() {
    if (isEvent) {
      return getEvent().eventID;
    } else if (isNews) {
      return getNews().postID;
    } else if (isBlogPost) {
      return getBlogPost().postID;
    } else if (isComplaintComment) {
      return getComment().id;
    }
    return "";
  }
}

@GenSerializer()
class NotificationSerializer extends Serializer<Notification>
    with _$NotificationSerializer {}
