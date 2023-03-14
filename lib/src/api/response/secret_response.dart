import 'package:json_annotation/json_annotation.dart';

part 'secret_response.g.dart';

@JsonSerializable()
class SecretResponse {
  String? message;

  SecretResponse({
    this.message,
  });
  factory SecretResponse.fromJson(Map<String, dynamic> json) =>
      _$SecretResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SecretResponseToJson(this);
}
