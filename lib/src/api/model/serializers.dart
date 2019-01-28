// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
library serializers;

import 'package:InstiApp/src/api/model/datetime.dart';
import 'package:InstiApp/src/api/model/notification.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/api/request/comment_create_request.dart';
import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/api/request/event_create_request.dart';
import 'package:InstiApp/src/api/request/image_upload_request.dart';
import 'package:InstiApp/src/api/request/user_fcm_patch_request.dart';
import 'package:InstiApp/src/api/response/complaint_create_response.dart';
import 'package:InstiApp/src/api/response/event_create_response.dart';
import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/api/response/news_feed_response.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/post.dart';

JsonRepo standardSerializers = JsonRepo(serializers: [
  // Mess menu
  HostelSerializer(),
  HostelMessSerializer(),
  
  // Session
  UserSerializer(),
  SessionSerializer(),

  // General
  BodySerializer(),
  EventSerializer(),
  VenueSerializer(),
  RoleSerializer(),
  NewsArticleSerializer(),
  NotificationSerializer(),
  DateTimeSerializer(),
  
  // Blog
  PostSerializer(),
  PlacementBlogPostSerializer(),
  TrainingBlogPostSerializer(),
  
  // Venter
  ComplaintSerializer(),
  TagUriSerializer(),
  CommentSerializer(),

  // Requests
  ComplaintCreateRequestSerializer(),
  EventCreateRequestSerializer(),
  ImageUploadRequestSerializer(),
  CommentCreateRequestSerializer(),
  UserFCMPatchRequestSerializer(),

  // Responses
  NewsFeedResponseSerializer(),
  ExploreResponseSerializer(),
  EventCreateResponseSerializer(),
  ImageUploadResponseSerializer(),
  ComplaintCreateResponseSerializer(),

]);