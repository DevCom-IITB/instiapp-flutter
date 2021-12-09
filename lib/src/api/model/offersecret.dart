
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'offersecret.g.dart';

class Offersecret {
  @JsonKey("secret")
  String secret;

  Offersecret({this.secret});

  factory Offersecret.fromJson(Map<String, dynamic> json) =>
      _$OffersecretFromJson(json);
  
  Map<String, dynamic> toJson() => _$OffersecretToJson(this);

}

@GenSerializer()
class OffersecretSerializer extends Serializer<Offersecret> with _$OffersecretSerializer {}

