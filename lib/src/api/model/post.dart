import 'package:InstiApp/src/api/model/body.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'post.jser.dart';

class Post {
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

class PlacementBlogPost extends Post{}
class TrainingBlogPost extends Post{}


class NewsArticle extends Post {
  @Alias("body")
  Body body;
}

@GenSerializer()
class NewsArticleSerializer extends Serializer<NewsArticle> with _$NewsArticleSerializer {}

@GenSerializer()
class PostSerializer extends Serializer<Post> with _$PostSerializer {}

@GenSerializer()
class PlacementBlogPostSerializer extends Serializer<PlacementBlogPost> with _$PlacementBlogPostSerializer {}

@GenSerializer()
class TrainingBlogPostSerializer extends Serializer<TrainingBlogPost> with _$TrainingBlogPostSerializer {}