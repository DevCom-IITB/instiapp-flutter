import 'mess.dart';
import 'dart:convert';

import 'serializers.dart';

List<Hostel> parseMess(String jsonStr) {
  final parsed = json.decode(jsonStr);
  final listOfHostels = List<dynamic>.from(parsed);
  // return standardSerializers.deserializeWith(Hostel.serializer, listOfHostels);
  return listOfHostels.map((hostel) => standardSerializers.deserializeWith(Hostel.serializer, hostel)).toList();
}

