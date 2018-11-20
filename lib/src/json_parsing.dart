import 'dart:convert';

import 'api/model/mess.dart';
import 'api/model/serializers.dart';

List<Hostel> parseMess(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listOfHostels = List<dynamic>.from(parsed);
  // return standardSerializers.deserializeWith(Hostel.serializer, listOfHostels);
  return listOfHostels.map((hostel) => standardSerializers.oneFrom<Hostel>(hostel)).toList();
}

