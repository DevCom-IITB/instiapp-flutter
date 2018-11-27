import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'dart:core';
part 'mess.jser.dart';

class Hostel{
  String id;
  String name;
  
  @Alias('short_name')
  String shortName;

  @Alias('long_name')
  String longName;
  
  List<HostelMess> mess;

  int compareTo(Hostel h) {
    int x = int.tryParse(this.shortName);
    if (x == null) {
      return this.shortName.compareTo(h.shortName);
    }
    int y = int.tryParse(h.shortName);
    if (y == null) {
      return this.shortName.compareTo(h.shortName);
    }
    return x.compareTo(y);
  }
}

class HostelMess {
  String id;
  int day;
  String breakfast;
  String lunch;
  String snacks;
  String dinner;
  String hostel;

  int compareTo(HostelMess h) {
    final now = DateTime.now();
    int today = now.weekday;

    int x = (this.day - today) + (this.day - today < 0 ? 7 : 0); 
    int y = (h.day - today) + (h.day - today < 0 ? 7 : 0); 

    return x.compareTo(y);
  }

  static Map<int, String> dayToName = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  getDayName() => dayToName[this.day];
}

@GenSerializer(serializers: const [HostelMessSerializer])
class HostelSerializer extends Serializer<Hostel> with _$HostelSerializer {}

@GenSerializer()
class HostelMessSerializer extends Serializer<HostelMess> with _$HostelMessSerializer {}