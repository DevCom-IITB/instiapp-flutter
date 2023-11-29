import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lostandfound.g.dart';

@JsonSerializable()
class LostAndFoundPost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "str_id")
  String? lostAndFoundPostStrId;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "product_image")
  List<String>? imageUrl;

  @JsonKey(name: "brand")
  String? foundAt;

  // @JsonKey(name: "warranty")
  // bool? warranty;
  //
  // @JsonKey(name: "packaging")
  // bool? packaging;

  @JsonKey(name: "condition")
  String? whenFound;

  @JsonKey(name: "action")
  String? action;

  @JsonKey(name: "status")
  bool? status;

  @JsonKey(name: "deleted")
  bool? deleted;

  @JsonKey(name: "price")
  bool? ifClaimed;

  // @JsonKey(name: "negotiable")
  // bool? negotiable;

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

  LostAndFoundPost({
    this.id,
    this.lostAndFoundPostStrId,
    this.name,
    this.description,
    this.imageUrl,
    this.foundAt,
    // this.warranty,
    // this.packaging,
    this.whenFound,
    this.action,
    this.status,
    this.deleted,
    this.ifClaimed,
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

  factory LostAndFoundPost.fromJson(Map<String, dynamic> json) =>
      _$LostAndFoundPostFromJson(json);

  Map<String, dynamic> toJson() => _$LostAndFoundPostToJson(this);

  getLostAndFoundPost(String s) {}
}
