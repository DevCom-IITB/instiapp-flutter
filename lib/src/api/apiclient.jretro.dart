// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiclient.dart';

// **************************************************************************
// JaguarHttpGenerator
// **************************************************************************

abstract class _$InstiAppApiClient implements ApiClient {
  final String basePath = "";
  Future<List<Hostel>> getHostelMess() async {
    var req = base.get.path(basePath).path("/mess");
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<Session> passwordLogin(String username, String password) async {
    var req = base.get
        .path(basePath)
        .path("/pass-login")
        .query("username", username)
        .query("password", password);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Session> passwordLoginFcm(
      String username, String password, String fcmId) async {
    var req = base.get
        .path(basePath)
        .path("/pass-login")
        .query("username", username)
        .query("password", password)
        .query("fcm_id", fcmId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Session> login(String code, String redir) async {
    var req = base.get
        .path(basePath)
        .path("/login")
        .query("code", code)
        .query("redir", redir);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<List<PlacementBlogPost>> getPlacementBlogFeed(
      String sessionId, int from, int number, String query) async {
    var req = base.get
        .path(basePath)
        .path("/placement-blog")
        .query("from", from)
        .query("num", number)
        .query("query", query)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<List<TrainingBlogPost>> getTrainingBlogFeed(
      String sessionID, int from, int num, String query) async {
    var req = base.get
        .path(basePath)
        .path("/training-blog")
        .query("from", from)
        .query("num", num)
        .query("query", query)
        .header("Cookie", sessionID);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<Event> getEvent(String sessionId, String uuid) async {
    var req = base.get
        .path(basePath)
        .path("/events/:uuid")
        .pathParams("uuid", uuid)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<NewsFeedResponse> getNewsFeed(String sessionId) async {
    var req =
    base.get.path(basePath).path("/events").header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<NewsFeedResponse> getEventsBetweenDates(
      String sessionId, String start, String end) async {
    var req = base.get
        .path(basePath)
        .path("/events")
        .query("start", start)
        .query("end", end)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<EventCreateResponse> createEvent(
      String sessionId, EventCreateRequest eventCreateRequest) async {
    var req = base.post
        .path(basePath)
        .path("/events")
        .header("Cookie", sessionId)
        .json(jsonConverter.to(eventCreateRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<List<Venue>> getAllVenues() async {
    var req = base.get.path(basePath).path("/locations");
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<List<Venue>> getVenue(String id) async {
    var req = base.get.path(basePath).path("/locations/:id").query("id", id);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<User> getUser(String sessionId, String uuid) async {
    var req = base.get
        .path(basePath)
        .path("/users/:uuid")
        .pathParams("uuid", uuid)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Body> getBody(String sessionId, String uuid) async {
    var req = base.get
        .path(basePath)
        .path("/bodies/:uuid")
        .pathParams("uuid", uuid)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<List<Body>> getAllBodies(String sessionId) async {
    var req =
    base.get.path(basePath).path("/bodies").header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<void> updateBodyFollowing(
      String sessionID, String eventID, int action) async {
    var req = base.get
        .path(basePath)
        .path("/bodies/:bodyID/follow")
        .pathParams("bodyID", eventID)
        .query("action", action)
        .header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<ImageUploadResponse> uploadImage(
      String sessionID, ImageUploadRequest imageUploadRequest) async {
    var req = base.post
        .path(basePath)
        .path("/upload")
        .header("Cookie", sessionID)
        .json(jsonConverter.to(imageUploadRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<User> getUserMe(String sessionID) async {
    var req =
    base.get.path(basePath).path("/user-me").header("Cookie", sessionID);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<void> updateUserEventStatus(
      String sessionID, String eventID, int status) async {
    var req = base.get
        .path(basePath)
        .path("/user-me/ues/:eventID")
        .pathParams("eventID", eventID)
        .query("status", status)
        .header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<void> updateUserNewsReaction(
      String sessionID, String postID, int reaction) async {
    var req = base.get
        .path(basePath)
        .path("/user-me/unr/:postID")
        .pathParams("postID", postID)
        .query("reaction", reaction)
        .header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<User> patchFCMUserMe(
      String sessionID, UserFCMPatchRequest userFCMPatchRequest) async {
    var req = base.patch
        .path(basePath)
        .path("/user-me")
        .header("Cookie", sessionID)
        .json(jsonConverter.to(userFCMPatchRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<User> patchSCNUserMe(
      String sessionID, UserSCNPatchRequest userSCNPatchRequest) async {
    var req = base.patch
        .path(basePath)
        .path("/user-me")
        .header("Cookie", sessionID)
        .json(jsonConverter.to(userSCNPatchRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<List<NewsArticle>> getNews(
      String sessionID, int from, int num, String query) async {
    var req = base.get
        .path(basePath)
        .path("/news")
        .query("from", from)
        .query("num", num)
        .query("query", query)
        .header("Cookie", sessionID);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<List<Notification>> getNotifications(String sessionID) async {
    var req = base.get
        .path(basePath)
        .path("/notifications")
        .header("Cookie", sessionID);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<void> markNotificationRead(
      String sessionID, String notificationID) async {
    var req = base.get
        .path(basePath)
        .path("/notifications/read/:notificationID")
        .pathParams("notificationID", notificationID)
        .header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<void> markAllNotificationsRead(String sessionID) async {
    var req = base.get
        .path(basePath)
        .path("/notifications/read")
        .header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<void> logout(String sessionID) async {
    var req =
    base.get.path(basePath).path("/logout").header("Cookie", sessionID);
    await req.go(throwOnErr: true);
  }

  Future<ExploreResponse> search(String sessionID, String query) async {
    var req = base.get
        .path(basePath)
        .path("/search")
        .query("query", query)
        .header("Cookie", sessionID);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<List<Complaint>> getAllComplaints(
      String sessionId, int from, int number, String query) async {
    var req = base.get
        .path(basePath)
        .path("/venter/complaints")
        .query("from", from)
        .query("num", number)
        .query("search", query)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<List<Complaint>> getUserComplaints(String sessionId) async {
    var req = base.get
        .path(basePath)
        .path("/venter/complaints?filter=me")
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeList);
  }

  Future<Complaint> getComplaint(String sessionId, String complaintId) async {
    var req = base.get
        .path(basePath)
        .path("/venter/complaints/:complaintId")
        .pathParams("complaintId", complaintId)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Complaint> upVote(
      String sessionId, String complaintId, int count) async {
    var req = base.get
        .path(basePath)
        .path("/venter/complaints/:complaintId/upvote")
        .pathParams("complaintId", complaintId)
        .query("action", count)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Complaint> subscribleToComplaint(
      String sessionId, String complaintId, int count) async {
    var req = base.get
        .path(basePath)
        .path("/venter/complaints/:complaintId/subscribe")
        .pathParams("complaintId", complaintId)
        .query("action", count)
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Complaint> postComplaint(
      String sessionId, ComplaintCreateRequest complaintCreateRequest) async {
    var req = base.post
        .path(basePath)
        .path("/venter/complaints")
        .header("Cookie", sessionId)
        .json(jsonConverter.to(complaintCreateRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Comment> postComment(String sessionId, String complaintId,
      CommentCreateRequest commentCreateRequest) async {
    var req = base.post
        .path(basePath)
        .path("/venter/complaints/:complaintId/comments")
        .pathParams("complaintId", complaintId)
        .header("Cookie", sessionId)
        .json(jsonConverter.to(commentCreateRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<Comment> updateComment(String sessionId, String commentId,
      CommentCreateRequest commentCreateRequest) async {
    var req = base.put
        .path(basePath)
        .path("/venter/comments/:commentId")
        .pathParams("commentId", commentId)
        .header("Cookie", sessionId)
        .json(jsonConverter.to(commentCreateRequest));
    return req.go(throwOnErr: true).map(decodeOne);
  }

  Future<void> deleteComment(String sessionId, String commentId) async {
    var req = base.delete
        .path(basePath)
        .path("/venter/comments/:commentId")
        .pathParams("commentId", commentId)
        .header("Cookie", sessionId);
    await req.go(throwOnErr: true);
  }

  Future<List<TagUri>> getAllTags(String sessionId) async {
    var req = base.get
        .path(basePath)
        .path("/venter/tags")
        .header("Cookie", sessionId);
    return req.go(throwOnErr: true).map(decodeList);
  }


  Future<AchievementCreateResponse> postForm(String sessionId,
      AchievementCreateRequest achievementCreateRequest) async {
    var req = base.post
        .path(basePath)
        .path("/achievements")
        .header("Cookie", sessionId)
        .json(jsonConverter.to(achievementCreateRequest));
    return await req.go(throwOnErr: true).map(decodeOne);
  }
}