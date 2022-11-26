import 'dart:convert';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/news_feed_response.dart';

List parseMess(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listOfHostels = List<dynamic>.from(parsed);
  // return standardSerializers.deserializeWith(Hostel.serializer, listOfHostels);
  return listOfHostels.map((e) => e.toJson()).toList();
  // return listOfHostels
  //     .map((hostel) => standardSerializers.oneFrom<Hostel>(hostel))
  //     .toList();
}

Session parseSession(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final session = Map<String, dynamic>.from(parsed);
  return Session.fromJson(session);
}

NewsFeedResponse parseEvents(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final newsFeedResponse = Map<String, dynamic>.from(parsed);
  return NewsFeedResponse.fromJson(newsFeedResponse);
}
