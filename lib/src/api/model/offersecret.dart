import 'package:json_annotation/json_annotation.dart';

part 'offersecret.g.dart';

@JsonSerializable()
class Offersecret {
  @JsonKey(name: "secret")
  String? secret;

  Offersecret({this.secret});

  factory Offersecret.fromJson(Map<String, dynamic> json) =>
      _$OffersecretFromJson(json);
  
  Map<String, dynamic> toJson() => _$OffersecretToJson(this);

}
