import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'complaint_create_request.jser.dart';

class ComplaintCreateRequest {
  @Alias("description")
  String complaintDescription;
  @Alias("location_description")
  String complaintLocation;
  @Alias("latitude")
  double complaintLatitude;
  @Alias("longitude")
  double complaintLongitude;
  @Alias("tags")
  List<String> tags;
  @Alias("images")
  List<String> images;
}

@GenSerializer()
class ComplaintCreateRequestSerializer extends Serializer<ComplaintCreateRequest> with _$ComplaintCreateRequestSerializer {}