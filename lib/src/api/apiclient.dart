import 'dart:async';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/notification.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/api/request/ach_verify_request.dart';
import 'package:InstiApp/src/api/request/achievement_create_request.dart';
import 'package:InstiApp/src/api/request/achievement_hidden_patch_request.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/api/request/event_create_request.dart';
import 'package:InstiApp/src/api/request/image_upload_request.dart';
import 'package:InstiApp/src/api/request/user_fcm_patch_request.dart';
import 'package:InstiApp/src/api/request/user_scn_patch_request.dart';
import 'package:InstiApp/src/api/response/achievement_create_response.dart';
import 'package:InstiApp/src/api/response/event_create_response.dart';
import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/api/response/news_feed_response.dart';
import 'package:InstiApp/src/api/response/secret_response.dart';
import 'package:http/io_client.dart';
// import 'package:http/browser_client.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/post.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_resty/jaguar_resty.dart';
import 'package:jaguar_resty/jaguar_resty.dart' as resty;
import 'package:jaguar_retrofit/jaguar_retrofit.dart';
import 'package:InstiApp/src/api/model/serializers.dart';

import 'model/offersecret.dart';

part 'apiclient.jretro.dart';

@GenApiClient()
class InstiAppApi extends ApiClient with _$InstiAppApiClient {
  static String endpoint = "http://10.0.2.2:8000/api";
  // static String endpoint = "https://api.insti.app/api";
  final resty.Route base = route(endpoint);
  // final JsonRepo jsonConverter = standardSerializers;
  // final SerializerRepo serializers = standardSerializers;

  static InstiAppApi _instance = InstiAppApi.internal();
  InstiAppApi.internal() {
    // if (kIsWeb) {
    //   globalClient = BrowserClient();
    // } else {
    globalClient = IOClient();
    // }
    jsonConverter = standardSerializers;
  }
  factory InstiAppApi() => _instance;

  @GetReq(path: "/mess")
  Future<List<Hostel>> getHostelMess();

  @GetReq(path: "/pass-login")
  Future<Session> passwordLogin(@QueryParam("username") String username,
      @QueryParam("password") String password);

  @GetReq(path: "/pass-login")
  Future<Session> passwordLoginFcm(
      @QueryParam("username") String username,
      @QueryParam("password") String password,
      @QueryParam("fcm_id") String fcmId);

  @GetReq(path: "/login")
  Future<Session> login(@QueryParam() String code, @QueryParam() String redir);

  @GetReq(path: "/placement-blog")
  Future<List<PlacementBlogPost>> getPlacementBlogFeed(
      @Header("Cookie") String sessionId,
      @QueryParam("from") int from,
      @QueryParam("num") int number,
      @QueryParam("query") String query);

  @GetReq(path: "/external-blog")
  Future<List<ExternalBlogPost>> getExternalBlogFeed(
      @Header("Cookie") String sessionId,
      @QueryParam("from") int from,
      @QueryParam("num") int number,
      @QueryParam("query") String query);

  @GetReq(path: "/training-blog")
  Future<List<TrainingBlogPost>> getTrainingBlogFeed(
      @Header("Cookie") String sessionID,
      @QueryParam("from") int from,
      @QueryParam("num") int num,
      @QueryParam("query") String query);

  // Events
  @GetReq(path: "/events/:uuid")
  Future<Event> getEvent(
      @Header("Cookie") String sessionId, @PathParam() String uuid);

  @GetReq(path: "/events")
  Future<NewsFeedResponse> getNewsFeed(@Header("Cookie") String sessionId);

  @GetReq(path: "/events")
  Future<NewsFeedResponse> getEventsBetweenDates(
      @Header("Cookie") String sessionId,
      @QueryParam("start") String start,
      @QueryParam("end") String end);

  @PostReq(path: "/events")
  Future<EventCreateResponse> createEvent(@Header("Cookie") String sessionId,
      @AsJson() EventCreateRequest eventCreateRequest);

  // Venues
  @GetReq(path: "/locations")
  Future<List<Venue>> getAllVenues();

  @GetReq(path: "/locations/:id")
  Future<List<Venue>> getVenue(@QueryParam("id") String id);

  // Users
  @GetReq(path: "/users/:uuid")
  Future<User> getUser(
      @Header("Cookie") String sessionId, @PathParam() String uuid);

  // Bodies
  @GetReq(path: "/bodies/:uuid")
  Future<Body> getBody(
      @Header("Cookie") String sessionId, @PathParam() String uuid);

  @GetReq(path: "/bodies")
  Future<List<Body>> getAllBodies(@Header("Cookie") String sessionId);

  @GetReq(path: "/bodies/:bodyID/follow")
  Future<void> updateBodyFollowing(@Header("Cookie") String sessionID,
      @PathParam("bodyID") String eventID, @QueryParam("action") int action);

  // Image upload
  @PostReq(path: "/upload")
  Future<ImageUploadResponse> uploadImage(@Header("Cookie") String sessionID,
      @AsJson() ImageUploadRequest imageUploadRequest);

  // My data
  @GetReq(path: "/user-me")
  Future<User> getUserMe(@Header("Cookie") String sessionID);

  @GetReq(path: "/user-me/ues/:eventID")
  Future<void> updateUserEventStatus(@Header("Cookie") String sessionID,
      @PathParam() String eventID, @QueryParam("status") int status);

  @GetReq(
    path: "/user-me/unr/:postID",
  )
  Future<void> updateUserNewsReaction(@Header("Cookie") String sessionID,
      @PathParam() String postID, @QueryParam("reaction") int reaction);

  @PatchReq(path: "/user-me")
  Future<User> patchFCMUserMe(@Header("Cookie") String sessionID,
      @AsJson() UserFCMPatchRequest userFCMPatchRequest);

  @PatchReq(path: "/user-me")
  Future<User> patchSCNUserMe(@Header("Cookie") String sessionID,
      @AsJson() UserSCNPatchRequest userSCNPatchRequest);

  @GetReq(path: "/news")
  Future<List<NewsArticle>> getNews(
      @Header("Cookie") String sessionID,
      @QueryParam("from") int from,
      @QueryParam("num") int num,
      @QueryParam("query") String query);

  @GetReq(path: "/notifications")
  Future<List<Notification>> getNotifications(
      @Header("Cookie") String sessionID);

  @GetReq(path: "/notifications/read/:notificationID")
  Future<void> markNotificationRead(
      @Header("Cookie") String sessionID, @PathParam() String notificationID);

  @GetReq(path: "/notifications/read")
  Future<void> markAllNotificationsRead(@Header("Cookie") String sessionID);

  @GetReq(path: "/logout")
  Future<void> logout(@Header("Cookie") String sessionID);

  // Explore search
  @GetReq(path: "/search")
  Future<ExploreResponse> search(
      @Header("Cookie") String sessionID, @QueryParam("query") String query);

  // Venter
  @GetReq(path: "/venter/complaints")
  Future<List<Complaint>> getAllComplaints(
      @Header("Cookie") String sessionId,
      @QueryParam("from") int from,
      @QueryParam("num") int number,
      @QueryParam("search") String query);

  @GetReq(path: "/venter/complaints?filter=me")
  Future<List<Complaint>> getUserComplaints(@Header("Cookie") String sessionId);

  @GetReq(path: "/venter/complaints/:complaintId")
  Future<Complaint> getComplaint(
      @Header("Cookie") String sessionId, @PathParam() String complaintId);

  @GetReq(path: "/venter/complaints/:complaintId/upvote")
  Future<Complaint> upVote(@Header("Cookie") String sessionId,
      @PathParam() String complaintId, @QueryParam("action") int count);

  @GetReq(path: "/venter/complaints/:complaintId/subscribe")
  Future<Complaint> subscribleToComplaint(@Header("Cookie") String sessionId,
      @PathParam() String complaintId, @QueryParam("action") int count);

  @PostReq(path: "/venter/complaints")
  Future<Complaint> postComplaint(@Header("Cookie") String sessionId,
      @AsJson() ComplaintCreateRequest complaintCreateRequest);

  @PostReq(path: "/venter/complaints/:complaintId/comments")
  Future<Comment> postComment(
      @Header("Cookie") String sessionId,
      @PathParam() String complaintId,
      @AsJson() CommentCreateRequest commentCreateRequest);

  @PutReq(path: "/venter/comments/:commentId")
  Future<Comment> updateComment(
      @Header("Cookie") String sessionId,
      @PathParam() String commentId,
      @AsJson() CommentCreateRequest commentCreateRequest);

  @DeleteReq(path: "/venter/comments/:commentId")
  Future<void> deleteComment(
      @Header("Cookie") String sessionId, @PathParam() String commentId);

  @GetReq(path: "/venter/tags")
  Future<List<TagUri>> getAllTags(@Header("Cookie") String sessionId);

  @PostReq(path: "/achievements")
  Future<AchievementCreateResponse> postForm(@Header("Cookie") String sessionId,
      @AsJson() AchievementCreateRequest achievementCreateRequest);

  @PostReq(path: "/achievements-offer/:id")
  Future<SecretResponse> postAchievementOffer(
      @Header("Cookie") String sessionId,
      @QueryParam() String id,
      @AsJson() Offersecret secret);

  @GetReq(path: "/achievements")
  Future<List<Achievement>> getYourAchievements(
      @Header("Cookie") String sessionId);

  @PatchReq(path: "/achievements/:id")
  Future<void> toggleHidden(@Header("Cookie") String sessionID,
      @PathParam() String id, @AsJson() AchievementHiddenPathRequest hidden);

  @GetReq(path: "/achievements-body/:id")
  Future<List<Achievement>> getBodyAchievements(
      @Header("Cookie") String sessionId, @PathParam() String id);

  @PutReq(path: "/achievements/:id")
  Future<void> dismissAchievement(@Header("Cookie") String sessionID,
      @PathParam() String id, @AsJson() AchVerifyRequest achievement);

  @DeleteReq(path: "/achievements/:id")
  Future<void> deleteAchievement(
      @Header("Cookie") String sessionID, @PathParam() String id);

  @GetReq(path: "/query")
  Future<List<Query>> getQueries(
      @Header("Cookie") String sessionID,
      @QueryParam("from") int from,
      @QueryParam("num") int num,
      @QueryParam("query") String query);
}
