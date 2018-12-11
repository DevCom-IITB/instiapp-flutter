import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'placementblogpost.jser.dart';

class PlacementBlogPost {
    @Alias("id")
    String postID;

    @Alias("link")
    String link;

    @Alias("title")
    String title;

    @Alias("content")
    String content;

    @Alias("published")
    String published;
}

@GenSerializer()
class PlacementBlogPostSerializer extends Serializer<PlacementBlogPost> with _$PlacementBlogPostSerializer {}