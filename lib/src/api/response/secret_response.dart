import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'secret_response.jser.dart';

class SecretResponse {
  String message;
}

@GenSerializer()
class SecretResponseSerializer
    extends Serializer<SecretResponse>
    with _$SecretResponseSerializer {}
