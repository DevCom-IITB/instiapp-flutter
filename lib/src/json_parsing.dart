import 'dart:convert';

import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/news_feed_response.dart';

import 'api/model/mess.dart';

List parseMess(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listOfHostels = List<dynamic>.from(parsed);
  // return standardSerializers.deserializeWith(Hostel.serializer, listOfHostels);
  return listOfHostels
      .map((hostel) => standardSerializers.oneFrom<Hostel>(hostel))
      .toList();
}

Session parseSession(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final session = Map<String, dynamic>.from(parsed);
  return standardSerializers.oneFrom<Session>(session);
}

NewsFeedResponse parseEvents(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final newsFeedResponse = Map<String, dynamic>.from(parsed);
  return standardSerializers.oneFrom<NewsFeedResponse>(newsFeedResponse);
}
