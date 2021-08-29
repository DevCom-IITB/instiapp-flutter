import 'package:InstiApp/src/api/model/achievements.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'secret_response.jser.dart';

class secret_response {
  String message;
}

@GenSerializer()
class secret_responseSerializer
    extends Serializer<secret_response>
    with _$secret_responseSerializer {}
