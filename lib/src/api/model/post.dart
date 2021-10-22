import 'package:InstiApp/src/api/model/body.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'post.jser.dart';

class Post {
  @Alias("id")
  String id;

  @Alias("guid")
  String guid;

  @Alias("link")
  String link;

  @Alias("title")
  String title;

  @Alias("content")
  String content;

  @Alias("published")
  String published;
}

class PlacementBlogPost extends Post {}

class ExternalBlogPost extends Post {
  @Alias("body")
  String body;
}

class TrainingBlogPost extends Post {}

class NewsArticle extends Post {
  @Alias("body")
  Body body;

  @Alias("reactions_count")
  Map<String, int> reactionCount;

  @Alias("user_reaction")
  int userReaction;
}

@GenSerializer()
class PostSerializer extends Serializer<Post> with _$PostSerializer {}

@GenSerializer()
class PlacementBlogPostSerializer extends Serializer<PlacementBlogPost>
    with _$PlacementBlogPostSerializer {}

@GenSerializer()
class ExternalBlogPostSerializer extends Serializer<ExternalBlogPost>
    with _$ExternalBlogPostSerializer {}

@GenSerializer()
class TrainingBlogPostSerializer extends Serializer<TrainingBlogPost>
    with _$TrainingBlogPostSerializer {}

@GenSerializer()
class NewsArticleSerializer extends Serializer<NewsArticle>
    with _$NewsArticleSerializer {}
