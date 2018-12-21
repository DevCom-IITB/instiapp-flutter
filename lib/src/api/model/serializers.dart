// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
library serializers;

import 'package:InstiApp/src/api/model/news_article.dart';
import 'package:InstiApp/src/api/model/notification.dart';
import 'package:InstiApp/src/api/model/role.dart';
import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/api/response/news_feed_response.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/blogpost.dart';

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
  
  // Blog
  PlacementBlogPostSerializer(),
  TrainingBlogPostSerializer(),
  
  // Venter
  ComplaintSerializer(),
  TagUriSerializer(),
  CommentSerializer(),

  // Responses
  NewsFeedResponseSerializer(),
]);