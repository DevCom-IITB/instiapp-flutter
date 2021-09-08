
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offersecret.jser.dart';

class Offersecret {
  @Alias("secret")
  String secret;

}

@GenSerializer()
class OffersecretSerializer extends Serializer<Offersecret> with _$OffersecretSerializer {}

