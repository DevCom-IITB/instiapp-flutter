import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'complaint_create_request.g.dart';

class ComplaintCreateRequest {
  @JsonKey("description")
  String complaintDescription;
  @JsonKey("suggestions")
  String complaintSuggestions;
  @JsonKey("location_details")
  String complaintLocationDetails;
  @JsonKey("location_description")
  String complaintLocation;
  @JsonKey("latitude")
  double complaintLatitude;
  @JsonKey("longitude")
  double complaintLongitude;
  @JsonKey("tags")
  List<String> tags;
  @JsonKey("images")
  List<String> images;

  ComplaintCreateRequest(
      {this.complaintDescription,
      this.complaintSuggestions,
      this.complaintLocationDetails,
      this.complaintLocation,
      this.complaintLatitude,
      this.complaintLongitude,
      this.tags,
      this.images});

  factory ComplaintCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ComplaintCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintCreateRequestToJson(this);
}

@GenSerializer()
class ComplaintCreateRequestSerializer
    extends Serializer<ComplaintCreateRequest>
    with _$ComplaintCreateRequestSerializer {}
