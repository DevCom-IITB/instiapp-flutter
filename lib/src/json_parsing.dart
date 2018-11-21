import 'dart:convert';

import 'package:instiapp/src/api/model/user.dart';

import 'api/model/mess.dart';
import 'api/model/serializers.dart';

List<Hostel> parseMess(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listOfHostels = List<dynamic>.from(parsed);
  // return standardSerializers.deserializeWith(Hostel.serializer, listOfHostels);
  return listOfHostels.map((hostel) => standardSerializers.oneFrom<Hostel>(hostel)).toList();
}

Session parseSession(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final session = Map<String, dynamic>.from(parsed);
  return standardSerializers.oneFrom<Session>(session);
}