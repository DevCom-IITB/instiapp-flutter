import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'buynsellPost.g.dart';

@JsonSerializable()
class BuynSellPost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "str_id")
  String? buysellPostStrId;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "product_image")
  List<String>? imageUrl;

  @JsonKey(name: "brand")
  String? brand;

  @JsonKey(name: "warranty")
  bool? warranty;

  @JsonKey(name: "packaging")
  bool? packaging;

  @JsonKey(name: "condition")
  String? condition;

  @JsonKey(name: "action")
  String? action;

  @JsonKey(name: "status")
  bool? status;

  @JsonKey(name: "deleted")
  bool? deleted;

  @JsonKey(name: "price")
  int? price;

  @JsonKey(name: "negotiable")
  bool? negotiable;

  @JsonKey(name: "contact_details")
  String? contactDetails;

  @JsonKey(name: "time_of_creation")
  String? timeOfCreation;

  @JsonKey(name: "category")
  String? category;

  @JsonKey(name: "user")
  User? user;

  @JsonKey(ignore: true)
  int? postedMinutes;

  @JsonKey(ignore: true)
  String? timeBefore;

  @override
  String toString() {
    return 'BuySellPost{id:$id, content:$name}';
  }

  BuynSellPost({
    this.id,
    this.buysellPostStrId,
    this.name,
    this.description,
    this.imageUrl,
    this.brand,
    this.warranty,
    this.packaging,
    this.condition,
    this.action,
    this.status,
    this.deleted,
    this.price,
    this.timeOfCreation,
    this.timeBefore,
  }) {
    if (timeOfCreation != null) {
      postedMinutes =
          DateTime.now().difference(DateTime.parse(timeOfCreation!)).inMinutes;
      if (postedMinutes! > 1440) {
        timeBefore = "${postedMinutes! ~/ 1440} Days Ago";
      } else if (postedMinutes! > 60) {
        timeBefore = "${postedMinutes! ~/ 60} Hours Ago";
      } else {
        timeBefore = "${postedMinutes!} Minutes Ago";
      }
    }
  }

  factory BuynSellPost.fromJson(Map<String, dynamic> json) =>
      _$BuynSellPostFromJson(json);

  Map<String, dynamic> toJson() => _$BuynSellPostToJson(this);

  getBuynSellPost(String s) {}
}
