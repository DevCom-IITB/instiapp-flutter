import 'package:json_annotation/json_annotation.dart';

part 'getencr_response.g.dart';

@JsonSerializable()
class GetEncrResponse {
  String? qrstring;

  GetEncrResponse({
    this.qrstring,
  });
  factory GetEncrResponse.fromJson(Map<String, dynamic> json) =>
      _$GetEncrResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GetEncrResponseToJson(this);
}
