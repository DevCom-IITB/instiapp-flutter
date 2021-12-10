// import 'package:jaguar_serializer/jaguar_serializer.dart';

// class DateTimeSerializer extends Serializer<DateTime>
//     with _$DateTimeSerializer {}

// abstract class _$DateTimeSerializer implements Serializer<DateTime> {
//   @override
//   Map<String, dynamic> toMap(DateTime model) {
//     if (model == null) return null;
//     Map<String, dynamic> ret = <String, dynamic>{};
//     setMapValue(ret, 'iso8601', model.toIso8601String());
//     return ret;
//   }

//   @override
//   DateTime fromMap(Map map) {
//     if (map == null) return null;
//     final obj = DateTime.parse(map['iso8601'] as String);
//     return obj;
//   }
// }
