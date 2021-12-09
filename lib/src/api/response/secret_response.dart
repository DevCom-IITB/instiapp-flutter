import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'secret_response.g.dart';

class SecretResponse {
  String message;

  SecretResponse({
    this.message,
  });
  factory SecretResponse.fromJson(Map<String, dynamic> json) =>
      _$SecretResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SecretResponseToJson(this);
}

@GenSerializer()
class SecretResponseSerializer
    extends Serializer<SecretResponse>
    with _$SecretResponseSerializer {}
