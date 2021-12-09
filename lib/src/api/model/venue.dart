import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'venue.g.dart';

class Venue {
  @JsonKey("id")
  String venueID;

  @JsonKey("name")
  String venueName;

  @JsonKey("short_name")
  String venueShortName;

  @JsonKey("description")
  String venueDescripion;

  @JsonKey("parent")
  String venueParentId;

  @JsonKey("parent_relation")
  String venueParentRelation;

  @JsonKey("group_id")
  int venueGroupId;

  @JsonKey("pixel_x")
  int venuePixelX;

  @JsonKey("pixel_y")
  int venuePixelY;

  @JsonKey("reusable")
  bool venueReusable;

  @JsonKey("lat")
  String venueLatitude;

  @JsonKey("lng")
  String venueLongitude;

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

@GenSerializer()
class VenueSerializer extends Serializer<Venue> with _$VenueSerializer {}
