import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@JsonSerializable()
class Venue {
  @JsonKey(name: "id")
  String? venueID;

  @JsonKey(name: "name")
  String? venueName;

  @JsonKey(name: "short_name")
  String? venueShortName;

  @JsonKey(name: "description")
  String? venueDescripion;

  @JsonKey(name: "parent")
  String? venueParentId;

  @JsonKey(name: "parent_relation")
  String? venueParentRelation;

  @JsonKey(name: "group_id")
  int? venueGroupId;

  @JsonKey(name: "pixel_x")
  int? venuePixelX;

  @JsonKey(name: "pixel_y")
  int? venuePixelY;

  @JsonKey(name: "reusable")
  bool? venueReusable;

  @JsonKey(name: "lat")
  String? venueLatitude;

  @JsonKey(name: "lng")
  String? venueLongitude;

  Venue(
      {this.venueID,
      this.venueName,
      this.venueShortName,
      this.venueDescripion,
      this.venueParentId,
      this.venueParentRelation,
      this.venueGroupId,
      this.venuePixelX,
      this.venuePixelY,
      this.venueReusable,
      this.venueLatitude,
      this.venueLongitude});
  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
  Map<String, dynamic> toJson() => _$VenueToJson(this);
}
