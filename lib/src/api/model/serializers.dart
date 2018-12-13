// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
library serializers;

import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/event.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/api/model/placementblogpost.dart';

JsonRepo standardSerializers = JsonRepo(serializers: [
  HostelSerializer(),
  HostelMessSerializer(),
  UserSerializer(),
  SessionSerializer(),
  BodySerializer(),
  EventSerializer(),
  PlacementBlogPostSerializer(),
]);