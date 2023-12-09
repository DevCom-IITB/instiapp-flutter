import 'package:InstiApp/src/api/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lostandfoundPost.g.dart';

@JsonSerializable()
class LostAndFoundPost {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "product_image")
  List<String>? imageUrl;

  @JsonKey(name: "category")
  String? category;

  @JsonKey(name: "found_at")
  String? foundAt;

  @JsonKey(name: "claimed")
  bool? claimed;

  @JsonKey(name: "contact_details")
  String? contactDetails;

  @JsonKey(name: "time_of_creation")
  String? timeOfCreation;

  @JsonKey(name: "claimed_by")
  User? claimedBy;

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
    this.name,
    this.description,
    this.imageUrl,
    this.foundAt,
    this.claimed,
    this.claimedBy,
    this.contactDetails,
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
