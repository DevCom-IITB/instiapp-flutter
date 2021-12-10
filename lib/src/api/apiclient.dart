import 'dart:async';
import 'dart:developer';

import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:InstiApp/src/api/model/body.dart' as bdy;
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
import 'package:InstiApp/src/api/request/postFAQ_request.dart';
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
import 'package:InstiApp/src/api/model/post.dart' as pst;
import 'package:InstiApp/src/api/model/user.dart';
// import 'package:jaguar_resty/jaguar_resty.dart';
// import 'package:jaguar_resty/jaguar_resty.dart' as resty;
// import 'package:jaguar_retrofit/jaguar_retrofit.dart';
// import 'package:InstiApp/src/api/model/serializers.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'model/offersecret.dart';


@RestApi(baseUrl: "https://api.insti.app/api")
abstract class InstiAppApi {
  factory InstiAppApi(Dio dio, {String baseUrl}) = _instance;

  @GET("/mess")
  Future<List<Hostel>> getHostelMess();

  @GET("/pass-login")
  Future<Session> passwordLogin(@Query("username") String username,
      @Query("password") String password);

  @GET("/pass-login")
  Future<Session> passwordLoginFcm(
      @Query("username") String username,
      @Query("password") String password,
      @Query("fcm_id") String fcmId);

  @GET("/login")
  Future<Session> login(@Query('code') String code, @Query('redir') String redir);

  @GET("/placement-blog")
  Future<List<pst.PlacementBlogPost>> getPlacementBlogFeed(
      @Header("Cookie") String sessionId,
      @Query("from") int from,
      @Query("num") int number,
      @Query("query") String query);

  @GET("/external-blog")
  Future<List<pst.ExternalBlogPost>> getExternalBlogFeed(
      @Header("Cookie") String sessionId,
      @Query("from") int from,
      @Query("num") int number,
      @Query("query") String query);

  @GET("/training-blog")
  Future<List<pst.TrainingBlogPost>> getTrainingBlogFeed(
      @Header("Cookie") String sessionID,
      @Query("from") int from,
      @Query("num") int num,
      @Query("query") String query);

  // Events
  @GET("/events/{uuid}")
  Future<Event> getEvent(
      @Header("Cookie") String sessionId, @Path() String uuid);

  @GET("/events")
  Future<NewsFeedResponse> getNewsFeed(@Header("Cookie") String sessionId);

  @GET("/events")
  Future<NewsFeedResponse> getEventsBetweenDates(
      @Header("Cookie") String sessionId,
      @Query("start") String start,
      @Query("end") String end);

  @POST("/events")
  Future<EventCreateResponse> createEvent(@Header("Cookie") String sessionId,
      @Body() EventCreateRequest eventCreateRequest);

  // Venues
  @GET("/locations")
  Future<List<Venue>> getAllVenues();

  @GET("/locations/{id}")
  Future<List<Venue>> getVenue(@Path() String id);

  // Users
  @GET("/users/{uuid}")
  Future<User> getUser(
      @Header("Cookie") String sessionId, @Path() String uuid);

  // Bodies
  @GET("/bodies/{uuid}")
  Future<bdy.Body> getBody(
      @Header("Cookie") String sessionId, @Path() String uuid);

  @GET("/bodies")
  Future<List<bdy.Body>> getAllBodies(@Header("Cookie") String sessionId);

  @GET("/bodies/{bodyID}/follow")
  Future<void> updateBodyFollowing(@Header("Cookie") String sessionID,
      @Path("bodyID") String eventID, @Query("action") int action);

  // Image upload
  @POST("/upload")
  Future<ImageUploadResponse> uploadImage(@Header("Cookie") String sessionID,
      @Body() ImageUploadRequest imageUploadRequest);

  // My data
  @GET("/user-me")
  Future<User> getUserMe(@Header("Cookie") String sessionID);

  @GET("/user-me/ues/{eventID}")
  Future<void> updateUserEventStatus(@Header("Cookie") String sessionID,
      @Path() String eventID, @Query("status") int status);

  @GET("/user-me/unr/{postID}")
  Future<void> updateUserNewsReaction(@Header("Cookie") String sessionID,
      @Path() String postID, @Query("reaction") int reaction);

  @PATCH("/user-me")
  Future<User> patchFCMUserMe(@Header("Cookie") String sessionID,
      @Body() UserFCMPatchRequest userFCMPatchRequest);

  @PATCH("/user-me")
  Future<User> patchSCNUserMe(@Header("Cookie") String sessionID,
      @Body() UserSCNPatchRequest userSCNPatchRequest);

  @GET("/news")
  Future<List<pst.NewsArticle>> getNews(
      @Header("Cookie") String sessionID,
      @Query("from") int from,
      @Query("num") int num,
      @Query("query") String query);

  @GET("/notifications")
  Future<List<Notification>> getNotifications(
      @Header("Cookie") String sessionID);

  @GET("/notifications/read/{notificationID}")
  Future<void> markNotificationRead(
      @Header("Cookie") String sessionID, @Path() String notificationID);

  @GET("/notifications/read")
  Future<void> markAllNotificationsRead(@Header("Cookie") String sessionID);

  @GET("/logout")
  Future<void> logout(@Header("Cookie") String sessionID);

  // Explore search
  @GET("/search")
  Future<ExploreResponse> search(
      @Header("Cookie") String sessionID, @Query("query") String query);

  // Venter
  @GET("/venter/complaints")
  Future<List<Complaint>> getAllComplaints(
      @Header("Cookie") String sessionId,
      @Query("from") int from,
      @Query("num") int number,
      @Query("search") String query);

  @GET("/venter/complaints?filter=me")
  Future<List<Complaint>> getUserComplaints(@Header("Cookie") String sessionId);

  @GET("/venter/complaints/{complaintId}")
  Future<Complaint> getComplaint(
      @Header("Cookie") String sessionId, @Path() String complaintId);

  @GET("/venter/complaints/{complaintId}/upvote")
  Future<Complaint> upVote(@Header("Cookie") String sessionId,
      @Path() String complaintId, @Query("action") int count);

  @GET("/venter/complaints/{complaintId}/subscribe")
  Future<Complaint> subscribleToComplaint(@Header("Cookie") String sessionId,
      @Path() String complaintId, @Query("action") int count);

  @POST("/venter/complaints")
  Future<Complaint> postComplaint(@Header("Cookie") String sessionId,
      @Body() ComplaintCreateRequest complaintCreateRequest);

  @POST("/venter/complaints/{complaintId}/comments")
  Future<Comment> postComment(
      @Header("Cookie") String sessionId,
      @Path() String complaintId,
      @Body() CommentCreateRequest commentCreateRequest);

  @PUT("/venter/comments/{commentId}")
  Future<Comment> updateComment(
      @Header("Cookie") String sessionId,
      @Path() String commentId,
      @Body() CommentCreateRequest commentCreateRequest);

  @DELETE("/venter/comments/{commentId}")
  Future<void> deleteComment(
      @Header("Cookie") String sessionId, @Path() String commentId);

  @GET("/venter/tags")
  Future<List<TagUri>> getAllTags(@Header("Cookie") String sessionId);

  @POST("/achievements")
  Future<AchievementCreateResponse> postForm(@Header("Cookie") String sessionId,
      @Body() AchievementCreateRequest achievementCreateRequest);

  @POST("/achievements-offer/{id}")
  Future<SecretResponse> postAchievementOffer(
      @Header("Cookie") String sessionId,
      @Query() String id,
      @Body() Offersecret secret);

  @GET("/achievements")
  Future<List<Achievement>> getYourAchievements(
      @Header("Cookie") String sessionId);

  @PATCH("/achievements/{id}")
  Future<void> toggleHidden(@Header("Cookie") String sessionID,
      @Path() String id, @Body() AchievementHiddenPathRequest hidden);

  @GET("/achievements-body/{id}")
  Future<List<Achievement>> getBodyAchievements(
      @Header("Cookie") String sessionId, @Path() String id);

  @PUT("/achievements/{id}")
  Future<void> dismissAchievement(@Header("Cookie") String sessionID,
      @Path() String id, @Body() AchVerifyRequest achievement);

  @DELETE("/achievements/:id")
  Future<void> deleteAchievement(
      @Header("Cookie") String sessionID, @Path() String id);

  @GET("/query")
  Future<List<pst.Query>> getQueries(
      @Header("Cookie") String sessionID,
      // @QueryParam("from") int from,
      // @QueryParam("num") int num,
      @Query("query") String query,
      @Query("category") String category);

  @POST("/query/add")
  Future<void> postFAQ(
      @Header("Cookie") String sessionId, @Body() PostFAQRequest request);

  @GET("/query/categories")
  Future<List<String>> getQueryCategories(@Header("Cookie") String sessionId);
}
