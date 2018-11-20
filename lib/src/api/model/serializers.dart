// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
library serializers;

import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:instiapp/src/api/model/login_response.dart';
import 'package:instiapp/src/api/model/mess.dart';

SerializerRepo standardSerializers = JsonRepo(serializers: [
  HostelSerializer(),
  HostelMessSerializer(),
  LoginResponseSerializer(),
]);