
import 'package:InstiApp/src/api/model/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offersecret.jser.dart';

class offersecret {
  @Alias("secret")
  String secret;

}

@GenSerializer()
class offersecretSerializer extends Serializer<offersecret> with _$offersecretSerializer {}

