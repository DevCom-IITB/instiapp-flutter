import 'package:json_annotation/json_annotation.dart';

part 'complaint_create_response.g.dart';

@JsonSerializable()
class ComplaintCreateResponse {
  String? result;
  String? complaintId;


  ComplaintCreateResponse({
    this.result,
    this.complaintId
  });
  factory ComplaintCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ComplaintCreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintCreateResponseToJson(this);
}
