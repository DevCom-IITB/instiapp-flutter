import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'blogpost.jser.dart';

class BlogPost {
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

class PlacementBlogPost extends BlogPost{}
class TrainingBlogPost extends BlogPost{}

@GenSerializer()
class PlacementBlogPostSerializer extends Serializer<PlacementBlogPost> with _$PlacementBlogPostSerializer {}

@GenSerializer()
class TrainingBlogPostSerializer extends Serializer<TrainingBlogPost> with _$TrainingBlogPostSerializer {}