import 'package:json_annotation/json_annotation.dart';

part 'complaint_create_request.g.dart';

@JsonSerializable()
class ComplaintCreateRequest {
  @JsonKey(name: "description")
  String? complaintDescription;
  @JsonKey(name: "suggestions")
  String? complaintSuggestions;
  @JsonKey(name: "location_details")
  String? complaintLocationDetails;
  @JsonKey(name: "location_description")
  String? complaintLocation;
  @JsonKey(name: "latitude")
  double? complaintLatitude;
  @JsonKey(name: "longitude")
  double? complaintLongitude;
  @JsonKey(name: "tags")
  List<String>? tags;
  @JsonKey(name: "images")
  List<String>? images;

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
