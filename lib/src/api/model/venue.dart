import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'venue.jser.dart';

class Venue {
  @Alias("id")
  String venueID;

  @Alias("name")
  String venueName;

  @Alias("short_name")
  String venueShortName;

  @Alias("description")
  String venueDescripion;

  @Alias("parent")
  String venueParentId;

  @Alias("parent_relation")
  String venueParentRelation;

  @Alias("group_id")
  int venueGroupId;

  @Alias("pixel_x")
  int venuePixelX;

  @Alias("pixel_y")
  int venuePixelY;

  @Alias("reusable")
  bool venueReusable;

  @Alias("lat")
  double venueLatitude;

  @Alias("lng")
  double venueLongitude;
}

@GenSerializer()
class VenueSerializer extends Serializer<Venue> with _$VenueSerializer {}